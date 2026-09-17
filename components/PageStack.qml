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

	// Do not use MainView.allowPageAnimations: that is false while this stack is
	// animating, which would zero the slide as soon as the transition starts.
	readonly property int animationDuration: Global.animationEnabled ? Theme.animation_page_slide_duration : 0
	// True while navigation is in flight and the stack has not settled: a page is
	// transitioning, or the page that was asked for is still being built. Anything
	// waiting for a navigation to complete must wait for this, not just for the
	// transitions, otherwise it acts on the page it was already on. Abandoned
	// incubators are not included: they must not block the user's next push.
	readonly property bool animating: transitioning || !!_pendingBuild

	// True only while a transition is running. Going back is allowed while a page is
	// being built - that is how the user cancels it - so the back path tests this
	// rather than 'animating'.
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
	// Incubators that were abandoned but cannot be aborted. finish() removes them when
	// they complete; teardown force-completes any that are still running.
	property var _abandonedIncubators: []
	// True while any page incubator is still running, including ones that were
	// abandoned. Content animations pause on this so they do not starve leftover
	// incubation on GX. Does not block pushPage(); that uses animating.
	readonly property bool incubating: !!_pendingBuild || _abandonedIncubators.length > 0
	// Component created by Qt.createComponent() while that URL is still compiling.
	// Destroyed if the compile is abandoned, so the load is cancelled.
	property var _pendingOwnedComponent
	property var _pendingCompileHandler
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

		'obj' is a page url, a Component, or an already-constructed page object.

		A page pushed by url is built asynchronously. Building one is slow, and we
		don't want to block the UI thread for that long. Building
		it a piece at a time between frames instead leaves the application running
		while the user waits, and the page is pushed once it is complete.

		Qt.createComponent() is asynchronous, so the first open of a page no longer
		blocks the UI while the file is loaded and compiled. Cached components may
		become ready immediately; only then is incubation started. Component-valued
		pages (option lists, device pages) are incubated the same way. Already-
		constructed Page objects are still pushed immediately.

		If the user leaves before the page is ready, the page is discarded rather than
		appearing on top of wherever they went instead. Only one page is being waited
		for at a time; a push made while another page is being built is ignored, as it
		was previously ignored because the UI was blocked. An owned Component that is
		still compiling is destroyed, which cancels the load. An incubator cannot be
		aborted, so more than one page can still be under construction if the user
		repeatedly starts and abandons opening pages after compilation has finished.

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

		if (typeof(obj) === "string") {
			// Compile the page file asynchronously, then incubate it.
			const component = Qt.createComponent(obj.indexOf("qrc:") === 0 ? obj : ".." + obj, Component.Asynchronous)
			_loadThenIncubate(component, obj, properties, operation, readyCallback, true)
			return null
		}
		if (obj && typeof obj.incubateObject === "function") {
			// Already a Component (option lists, device pages); incubate it.
			_loadThenIncubate(obj, "", properties, operation, readyCallback, false)
			return null
		}

		const page = _pushItem(obj, properties, operation)
		if (!page) {
			console.warn("Aborted attempt to push page because StackView rejected the page object")
			return null
		}
		root._pageUrls.push("")
		root._topPageUrl = ""
		if (readyCallback) {
			readyCallback(page)
		}
		return page
	}

	function _releaseOwnedComponent(component, owned) {
		if (owned && component) {
			component.destroy()
		}
	}

	function _disconnectCompileHandler(component) {
		const handler = root._pendingCompileHandler
		root._pendingCompileHandler = null
		if (component && handler) {
			component.statusChanged.disconnect(handler)
		}
	}

	function _loadThenIncubate(component, pageUrl, properties, operation, readyCallback, owned) {
		if (!component || component.status === Component.Error) {
			console.warn("Aborted attempt to push page with errors: " + pageUrl + ": " + (component ? component.errorString() : "Qt.createComponent() failed"))
			_releaseOwnedComponent(component, owned)
			return
		}
		root._pendingOrigin = Global.mainView ? Global.mainView.currentPage : null
		if (component.status === Component.Ready) {
			_incubateAndPush(component, pageUrl, properties, operation, readyCallback, owned)
			return
		}

		const onStatusChanged = function() {
			if (root._pendingBuild !== component) {
				return
			}
			if (component.status === Component.Loading) {
				return
			}
			_disconnectCompileHandler(component)
			root._pendingOwnedComponent = null
			if (component.status === Component.Ready) {
				_incubateAndPush(component, pageUrl, properties, operation, readyCallback, owned)
				return
			}
			root._pendingBuild = null
			root._pendingOrigin = null
			console.warn("Aborted attempt to push page with errors: " + pageUrl + ": "
					+ component.errorString() + ", component status " + component.status)
			_releaseOwnedComponent(component, owned)
		}

		root._pendingBuild = component
		root._pendingOwnedComponent = owned ? component : null
		root._pendingCompileHandler = onStatusChanged
		component.statusChanged.connect(onStatusChanged)
		// Status may have changed after the Ready check above and before connect.
		if (component.status !== Component.Loading) {
			onStatusChanged()
		}
	}

	function _incubateAndPush(component, pageUrl, properties, operation, readyCallback, owned) {
		// incubateObject() returns null if given an undefined properties argument.
		const incubator = component.incubateObject(null, properties || {}, Qt.Asynchronous)
		if (!incubator) {
			if (root._pendingBuild === component) {
				root._pendingBuild = null
			}
			root._pendingOrigin = null
			root._pendingOwnedComponent = null
			console.warn("Aborted attempt to push page: " + pageUrl + ": could not start building it")
			_releaseOwnedComponent(component, owned)
			return
		}
		root._pendingBuild = incubator
		root._pendingOwnedComponent = null
		root._pendingCompileHandler = null

		// Going back is not the only way to leave: while the stack is closed the user can
		// also swipe to another main page, which does not touch the stack at all. So
		// remember the page this was asked from; leaving it abandons the build, see
		// the _shownPage handler below.
		const origin = root._pendingOrigin
		let finished = false

		const finish = function() {
			if (finished) {
				return
			}
			finished = true
			incubator.onStatusChanged = function() {}

			const stillPending = root._pendingBuild === incubator
			if (stillPending) {
				root._pendingBuild = null
				root._pendingOrigin = null
			}
			_untrackAbandonedIncubator(incubator)
			if (incubator.status !== Component.Ready) {
				console.warn("Aborted attempt to push page with errors: " + pageUrl)
				_releaseOwnedComponent(component, owned)
				return
			}
			// The origin is checked again here as a backstop, in case the page being
			// shown changed without MainView::currentPage ever reporting it.
			if (!stillPending || (Global.mainView && Global.mainView.currentPage !== origin)) {
				// The user left while this page was being built, so it is no longer wanted.
				// Do not destroy a page that StackView already parented (finish ran twice).
				if (incubator.object && !Theme.objectHasQObjectParent(incubator.object)) {
					incubator.object.destroy()
				}
				_releaseOwnedComponent(component, owned)
				return
			}
			const page = _pushItem(incubator.object, properties, operation)
			if (!page) {
				if (incubator.object && !Theme.objectHasQObjectParent(incubator.object)) {
					incubator.object.destroy()
				}
				console.warn("Aborted attempt to push page because StackView rejected the page object: " + pageUrl)
				_releaseOwnedComponent(component, owned)
				return
			}
			root._pageUrls.push(pageUrl)
			root._topPageUrl = pageUrl
			// The page no longer depends on the Component after _pushItem.
			// Release before readyCallback so a throw cannot leak it.
			_releaseOwnedComponent(component, owned)
			if (readyCallback) {
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
	}

	function _pushItem(page, properties, operation) {
		if (root.state !== "opened") {
			// When the stack is closed or hidden, push the first page without any animation and
			// slide the stack into view.
			const newPage = root.push(page, properties, StackView.Immediate)
			if (!newPage) {
				return null
			}
			fakePushAnimation.duration = _animationDuration(operation)
			root.state = "opened"
			return newPage
		}
		// Otherwise, push the page onto the visible stack, possibly with an animation.
		return root.push(page, properties, _adjustedStackOperation(operation))
	}

	function _untrackAbandonedIncubator(incubator) {
		const list = root._abandonedIncubators
		if (!list || list.length === 0) {
			return
		}
		const index = list.indexOf(incubator)
		if (index >= 0) {
			const next = list.slice()
			next.splice(index, 1)
			root._abandonedIncubators = next
		}
	}

	function _forceCompleteIncubator(incubator) {
		if (incubator && typeof incubator.forceCompletion === "function") {
			incubator.forceCompletion()
		}
	}

	// Abandons the page currently being built, if any, so that it is discarded instead
	// of being pushed when it is ready.
	//
	// An owned Component that is still compiling is destroyed, which cancels the load.
	// An incubator cannot be aborted: the work continues in the background and its
	// result is destroyed on completion, so a user who repeatedly starts and abandons
	// opening pages after compilation has finished can have more than one incubation
	// running at once. Those incubators are tracked until finish() or until the stack
	// is destroyed, so teardown can force-complete them instead of leaving a closure
	// that dereferences a dead root.
	function _abandonPendingBuild() {
		const pending = root._pendingBuild
		const owned = root._pendingOwnedComponent
		root._pendingBuild = null
		root._pendingOrigin = null
		root._pendingOwnedComponent = null
		_disconnectCompileHandler(pending)
		if (owned) {
			owned.destroy()
		} else if (pending && typeof pending.forceCompletion === "function") {
			const list = (root._abandonedIncubators || []).slice()
			list.push(pending)
			root._abandonedIncubators = list
		}
	}

	// A build in flight holds a closure that dereferences root unconditionally. The
	// stack can be destroyed before that closure runs: Main.qml's rebuildUi() drops
	// guiLoader on a backend connection loss, a demo-mode change or a plugin reload,
	// and popAllPages() cannot be relied on to have abandoned the build first because
	// _canPopTo() lets the current page veto the pop.
	//
	// Clear _pendingBuild and take the abandoned list before forcing completion, so
	// finish() takes its "no longer wanted" branch and destroys the built page instead
	// of pushing it onto a stack that is going away. Abandoned incubators are included:
	// they are no longer in _pendingBuild, but their finish closures still dereference
	// root. Forcing completion blocks, but this only happens while the UI is being torn
	// down, where a hitch does not matter.
	//
	// A Component that is still compiling has no forceCompletion(). Disconnect its
	// statusChanged handler and destroy it if we created it, so the handler cannot
	// run after this object is gone.
	Component.onDestruction: {
		const pending = root._pendingBuild
		const owned = root._pendingOwnedComponent
		const abandoned = root._abandonedIncubators
		root._pendingBuild = null
		root._pendingOrigin = null
		root._pendingOwnedComponent = null
		root._abandonedIncubators = []
		_disconnectCompileHandler(pending)
		if (pending && typeof pending.forceCompletion === "function") {
			pending.forceCompletion()
		} else if (owned) {
			owned.destroy()
		}
		for (let i = 0; i < abandoned.length; ++i) {
			_forceCompleteIncubator(abandoned[i])
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
