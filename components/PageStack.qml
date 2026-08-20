/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

StackView {
	id: root

	// True when fully opened (i.e. opened, and not animating in or out of the opened state).
	readonly property bool opened: _fullyOpened
	readonly property Page currentPage: opened ? currentItem : null

	readonly property int animationDuration: Global.mainView && Global.mainView.allowPageAnimations ? Theme.animation_page_slide_duration : 0
	// True while navigation is in flight and the stack has not settled: a page is
	// transitioning, or the page that was asked for is still being built. Anything
	// waiting for a navigation to complete must wait for this, not just for the
	// transitions, otherwise it acts on the page it was already on.
	readonly property bool animating: transitioning || !!_pendingBuild

	// True only while a transition is running. Going back is allowed while a page is
	// being built - that is how the user cancels it - so the back path tests this
	// rather than 'animating'. This is also what page animations should be disabled
	// for: a page being built is not a reason to stop animating what is on screen.
	readonly property bool transitioning: busy || fakePushTransition.running || fakePopTransition.running

	// The file url of the top page on the stack. Undefined if depth=0 or not opened, or an empty
	// string if the top page is from a component (and so no url is available).
	property var topPageUrl: opened ? _topPageUrl : undefined

	property var _pageUrls: []

	// The incubator of the page currently being built, if any, and the page that was
	// being shown when it was asked for. Cleared when the page is no longer wanted,
	// which is how a build that has been superseded is discarded.
	property var _pendingBuild
	property Page _pendingOrigin
	property Page _poppedPage
	property var _topPageUrl
	property bool _fullyOpened

	// Slide new drill-down pages in from the right
	pushEnter: Transition {
		XAnimator {
			from: width
			to: 0
			duration: root.animationDuration
			easing.type: Easing.InOutQuad
		}
	}

	pushExit: Transition {
		XAnimator {
			from: 0
			to: -width
			duration: root.animationDuration
			easing.type: Easing.InOutQuad
		}
	}
	popEnter: Transition {
		XAnimator {
			from: -width
			to: 0
			duration: root.animationDuration
			easing.type: Easing.InOutQuad
		}
	}

	popExit: Transition {
		SequentialAnimation {
			XAnimator {
				from: 0
				to: width
				duration: root.animationDuration
				easing.type: Easing.InOutQuad
			}
			ScriptAction {
				script: {
					// Clean up the page object that was created on push.
					if (root._poppedPage && !Theme.objectHasQObjectParent(root._poppedPage)) {
						root._poppedPage.destroy()
					}
					root._poppedPage = null
				}
			}
		}
	}

	/*
		Pushes a page onto the stack.

		'obj' is either a page url or an already-constructed page object.

		A page pushed by url is built asynchronously. Building one is slow: before the
		port to DelegateComponentModel the median page took 329ms to instantiate on a
		Cerbo GX and the worst 691ms, and building it synchronously blocked the UI
		thread for that long, so the whole application stopped responding until the
		page was ready. Building it a piece at a time between frames instead leaves
		the application running while the user waits, and the page is pushed once it
		is complete.

		Lazy delegate construction has since cut those figures to a 195ms median and
		481ms worst, so the block this avoids is smaller than it was — but it is
		still far more than a frame, and it is the pages that are slowest to build
		that the user is most likely to notice.

		Note that the Qt.createComponent() call is still synchronous, so the first
		time a given page is opened the UI does still block while the page is
		loaded, and compiled if it has to be. On a GX device that is a median of
		86ms and a worst measured case of 309ms with Qt's on-disk bytecode cache
		empty, and 21ms and 124ms with it populated; a real device sits between the
		two, as the cache is per source file rather than per page. Either way only
		the first open of a page in a given run pays it.

		If the user leaves before the page is ready, the page is discarded rather than
		appearing on top of wherever they went instead. Only one page is being waited
		for at a time; a push made while another page is being built is ignored, as it
		was previously ignored because the UI was blocked. Note that abandoning a build
		does not stop it, so more than one page can be under construction at once if
		the user repeatedly starts and abandons opening pages.

		Because the page does not exist yet when this returns, a page object is
		returned only when one was pushed synchronously, i.e. when 'obj' is already a
		page object. Pass 'readyCallback' to be given the page once it is on the
		stack; it is not called if the page was discarded or could not be built.
	*/
	function pushPage(obj, properties, operation, readyCallback) {
		if (root.animating) {
			return null
		}
		if (state === "hidden") {
			// If the stack was hidden, it now contains pages that are no longer relevant. Clear all
			// pages on the stack, without changing the state to closed.
			_popAndDestroyAllPages(StackView.Immediate)
		}

		if (typeof(obj) !== "string") {
			root._pageUrls.push("")
			root._topPageUrl = ""
			const page = _pushItem(obj, properties, operation)
			if (page && readyCallback) {
				readyCallback(page)
			}
			return page
		}

		// Compile the page first, to make sure there are no errors, to avoid messing up the page
		// stack state. Qt caches the compiled unit, so this is only slow the first time.
		const component = Qt.createComponent(obj.indexOf("qrc:") === 0 ? obj : ".." + obj)
		if (component.status !== Component.Ready) {
			console.warn("Aborted attempt to push page with errors: " + obj + ": " + component.errorString())
			return null
		}

		// incubateObject() returns null if given an undefined properties argument.
		const incubator = component.incubateObject(null, properties || {}, Qt.Asynchronous)
		if (!incubator) {
			console.warn("Aborted attempt to push page: " + obj + ": could not start building it")
			return null
		}
		root._pendingBuild = incubator

		// Going back is not the only way to leave: while the stack is closed the user can
		// also swipe to another main page, which does not touch the stack at all. So
		// remember the page this was asked from; leaving it abandons the build, see
		// the _shownPage handler below.
		root._pendingOrigin = Global.mainView ? Global.mainView.currentPage : null
		const origin = root._pendingOrigin

		const finish = function() {
			const stillPending = root._pendingBuild === incubator
			if (stillPending) {
				root._pendingBuild = null
			}
			if (incubator.status !== Component.Ready) {
				console.warn("Aborted attempt to push page with errors: " + obj)
				return
			}
			// The origin is checked again here as a backstop, in case the page being
			// shown changed without MainView::currentPage ever reporting it.
			if (!stillPending || (Global.mainView && Global.mainView.currentPage !== origin)) {
				// The user left while this page was being built, so it is no longer wanted.
				incubator.object.destroy()
				return
			}
			root._pageUrls.push(obj)
			root._topPageUrl = obj
			const page = _pushItem(incubator.object, properties, operation)
			if (page && readyCallback) {
				readyCallback(page)
			}
		}

		if (incubator.status === Component.Loading) {
			incubator.onStatusChanged = function(status) {
				if (status !== Component.Loading) {
					finish()
				}
			}
		} else {
			// A page small enough to be built within the first slice is already done.
			finish()
		}
		return null
	}

	function _pushItem(page, properties, operation) {
		if (root.state !== "opened") {
			// When the stack is closed or hidden, push the first page without any animation and
			// slide the stack into view.
			const newPage = root.push(page, properties, StackView.Immediate)
			fakePushAnimation.duration = _animationDuration(operation)
			root.state = "opened"
			return newPage
		}
		// Otherwise, push the page onto the visible stack, possibly with an animation.
		return root.push(page, properties, _adjustedStackOperation(operation))
	}

	// Abandons the page currently being built, if any, so that it is discarded instead
	// of being pushed when it is ready.
	//
	// Note that this does not stop the build: a QML incubator cannot be aborted. The
	// work continues in the background and its result is destroyed on completion, so a
	// user who repeatedly starts and abandons page opens can have more than one build
	// running at once.
	function _abandonPendingBuild() {
		root._pendingBuild = null
		root._pendingOrigin = null
	}

	// A build in flight holds a closure that dereferences root unconditionally. The
	// stack can be destroyed before that closure runs: Main.qml's rebuildUi() drops
	// guiLoader on a backend connection loss, a demo-mode change or a plugin reload,
	// and popAllPages() cannot be relied on to have abandoned the build first because
	// _canPopTo() lets the current page veto the pop.
	//
	// Clear _pendingBuild before forcing completion, so finish() takes its
	// "no longer wanted" branch and destroys the built page instead of pushing it onto
	// a stack that is going away. Forcing completion blocks, but this only happens
	// while the UI is being torn down, where a hitch does not matter.
	Component.onDestruction: {
		const incubator = root._pendingBuild
		if (incubator) {
			root._pendingBuild = null
			root._pendingOrigin = null
			incubator.forceCompletion()
		}
	}

	// Abandon the page being built as soon as the user leaves the page they asked for
	// it from, rather than only noticing once it is ready. Otherwise the stack counts
	// as busy for the rest of the build and silently drops whatever the user asks for
	// on the page they moved to, and a user who left and came back would be given the
	// page they had already abandoned.
	//
	// This arrives at the end of the turn in which the user left rather than during
	// it, because MainView::currentPage is itself a binding.
	readonly property Page _shownPage: Global.mainView ? Global.mainView.currentPage : null
	on_ShownPageChanged: {
		if (root._pendingBuild && root._shownPage !== root._pendingOrigin) {
			root._abandonPendingBuild()
		}
	}

	function popAllPages(operation) {
		if (!_canPopTo(null)) {
			return
		}
		_abandonPendingBuild()
		fakePopAnimation.duration = _animationDuration(operation)
		root.state = "closed"
	}

	function popPage(toPage, operation) {
		if (toPage === null) {
			popAllPages(operation)
			return
		}

		if (!_canPopTo(toPage)) {
			return
		}
		_abandonPendingBuild()
		root._pageUrls.pop()
		root._topPageUrl = root._pageUrls[root._pageUrls.length-1]

		if (root.depth === 1) {
			// When the last page is removed from the stack, move the stack out of view.
			fakePopAnimation.duration = _animationDuration(operation)
			root.state = "closed"
		} else {
			// Pop and delay destruction of the popped page until the animation completes,
			// otherwise the page disappears immediately.
			_poppedPage = root.pop(toPage, _adjustedStackOperation(operation))
		}
	}

	function show() {
		if (transitioning || state === "opened" || depth === 0) {
			return false
		}
		fakePushAnimation.duration = _animationDuration(StackView.PushTransition)
		state = "opened"
		return true
	}

	function hide() {
		if (transitioning || state !== "opened") {
			return false
		}
		_abandonPendingBuild()
		fakePopAnimation.duration = _animationDuration(StackView.PopTransition)
		state = "hidden"
		return true
	}

	function _popAndDestroyAllPages(operation) {
		_abandonPendingBuild()
		root._pageUrls = []
		root._topPageUrl = undefined

		while (root.depth > 1) {
			const page = root.pop(operation)
			if (page && !Theme.objectHasQObjectParent(page)) {
				page.destroy()
			}
		}

		// pop() only works for depth > 1
		const obj = root.currentItem
		root.clear()

		// Clean up the page object that was created in pushPage().
		if (obj && !Theme.objectHasQObjectParent(obj)) {
			obj.destroy()
		}
	}

	function _canPopTo(toPage) {
		if (root.transitioning
				|| (!!root.currentItem && !!root.currentItem.tryPop && !root.currentItem.tryPop(toPage))) {
			return false
		}
		return true
	}

	function _animationDuration(operation) {
		return Global.allPagesLoaded && operation !== StackView.Immediate ? root.animationDuration : 0
	}

	function _adjustedStackOperation(operation) {
		return Global.allPagesLoaded && operation !== StackView.Immediate ? operation : StackView.Immediate
	}

	// The stack is initially off-screen, and slides into view when the first page is pushed.
	x: Theme.geometry_screen_width
	width: Theme.geometry_screen_width
	state: "closed"
	enabled: opened

	states: [
		State {
			name: "opened"
			PropertyChanges {
				target: root
				x: 0
			}
		}
	]

	transitions: [
		Transition {
			id: fakePushTransition

			to: "opened"

			SequentialAnimation {
				NumberAnimation {   // Cannot use XAnimator, it will abruptly reset the StackView x.
					id: fakePushAnimation

					property: "x"
					easing.type: Easing.InOutQuad
				}
				ScriptAction {
					script: root._fullyOpened = true
				}
			}
		},
		Transition {
			id: fakePopTransition

			from: "opened"

			SequentialAnimation {
				ScriptAction {
					script: root._fullyOpened = false
				}
				NumberAnimation {   // Cannot use XAnimator, it will abruptly reset the StackView x.
					id: fakePopAnimation
					property: "x"
					easing.type: Easing.InOutQuad
				}
				ScriptAction {
					script: {
						if (root.state === "hidden") {
							// The stack is just being hidden temporarily; do not pop all pages.
							return
						}

						// When leaving the page stack destroy all the pages
						root._popAndDestroyAllPages(fakePopAnimation.duration > 0 ? StackView.PopTransition : StackView.Immediate)
					}
				}
			}
		}
	]
}
