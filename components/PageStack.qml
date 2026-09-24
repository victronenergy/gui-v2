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

	// Not MainView.allowPageAnimations: that is false during this slide.
	readonly property int animationDuration: Global.animationEnabled ? Theme.animation_page_slide_duration : 0
	// True while a transition is running or the requested page is still building.
	// Abandoned incubators are omitted so they do not block the next push.
	readonly property bool animating: transitioning || !!_pendingBuild

	// True only while a transition is running. Back uses this, not animating.
	readonly property bool transitioning: busy || fakePushTransition.running || fakePopTransition.running

	// The file url of the top page on the stack. Undefined if depth=0 or not opened, or an empty
	// string if the top page is from a component (and so no url is available).
	property var topPageUrl: opened ? _topPageUrl : undefined

	property var _pageUrls: []

	// Incubator (or compiling Component) of the page being built, plus origin.
	property var _pendingBuild
	property Page _pendingOrigin
	// Abandoned incubators that cannot be aborted. finish() or teardown clears them.
	property var _abandonedIncubators: []
	// Includes abandoned incubators so content animations do not starve them on GX.
	readonly property bool incubating: !!_pendingBuild || _abandonedIncubators.length > 0
	// Owned compiling Component; destroyed if the compile is abandoned.
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
				script: root._finishPoppedPage()
			}
		}
	}

	/*
		Pushes a page onto the stack.

		'obj' is a page url, a Component, or an already-constructed page object.

		URL and Component pages are built asynchronously so construction does
		not block the UI. Already-constructed Page objects are pushed immediately.

		Leaving before the page is ready discards it. A push while another is
		being built is ignored. Incubators cannot be aborted.

		Returns the page only for a synchronous push. Pass 'readyCallback' to
		receive it once it is on the stack (not called if discarded or failed).
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

		// Remember the origin page; leaving it abandons the build.
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
			// Origin may have changed without MainView.currentPage reporting it.
			if (!stillPending || (Global.mainView && Global.mainView.currentPage !== origin)) {
				// No longer wanted. Do not destroy a page StackView already parented.
				_discardIncubatedPage(incubator.object)
				_releaseOwnedComponent(component, owned)
				return
			}
			const page = _pushItem(incubator.object, properties, operation)
			if (!page) {
				_discardIncubatedPage(incubator.object)
				console.warn("Aborted attempt to push page because StackView rejected the page object: " + pageUrl)
				_releaseOwnedComponent(component, owned)
				return
			}
			root._pageUrls.push(pageUrl)
			root._topPageUrl = pageUrl
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
			// A page built in the first slice is already done.
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

	// Call only when Ready. aboutToBeDiscarded must not run while nested
	// AsynchronousIfNested delegates are still Loading.
	function _discardIncubatedPage(page) {
		if (!page || Theme.objectHasQObjectParent(page)) {
			return
		}
		if (page.aboutToBeDiscarded) {
			page.aboutToBeDiscarded()
		}
		page.destroy()
	}

	// Discard the in-flight page instead of pushing it. Destroying a compiling
	// Component cancels the load; incubators cannot be aborted, so they are
	// tracked until finish() or teardown force-completes them.
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

	// finish() closures dereference root. Clear pending/abandoned first so
	// forceCompletion() destroys the page instead of pushing it. Compiling
	// Components have no forceCompletion(); disconnect and destroy those.
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

	// Abandon as soon as the user leaves the origin. currentPage updates
	// at end of turn because it is a binding.
	readonly property Page _shownPage: Global.mainView ? Global.mainView.currentPage : null
	on_ShownPageChanged: {
		if (root._pendingBuild && root._shownPage !== root._pendingOrigin) {
			root._abandonPendingBuild()
		}
	}

	function _discardPagesUntil(toPage, skipPage) {
		for (let i = root.depth - 1; i >= 0; --i) {
			const item = root.get(i, StackView.DontLoad)
			if (item === toPage) {
				break
			}
			if (item && item !== skipPage && item.aboutToBeDiscarded) {
				item.aboutToBeDiscarded()
			}
		}
	}

	// Emit aboutToBeDiscarded once, after the slide, so the page stays
	// visible during the transition and destroy does not emit twice.
	function _finishPoppedPage() {
		const page = root._poppedPage
		if (!page) {
			return
		}
		root._poppedPage = null
		if (page.aboutToBeDiscarded) {
			page.aboutToBeDiscarded()
		}
		if (!Theme.objectHasQObjectParent(page)) {
			page.destroy()
		}
	}

	// UI teardown. popAllPages() can be vetoed, and a hidden stack never
	// runs the close transition. Stops in-flight slides; ignores tryPop.
	function destroyAllPages() {
		if (fakePushSequence.running) {
			fakePushSequence.stop()
		}
		if (fakePopSequence.running) {
			fakePopSequence.stop()
		}
		_popAndDestroyAllPages(StackView.Immediate)
		root._fullyOpened = false
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
		// No-target pop is one page. _discardPagesUntil(undefined) would
		// notify pages that stay on the stack.
		const discardToPage = toPage === undefined && root.depth > 1
			? root.get(root.depth - 2, StackView.DontLoad)
			: toPage
		root._pageUrls.pop()
		root._topPageUrl = root._pageUrls[root._pageUrls.length-1]

		if (root.depth === 1) {
			// When the last page is removed from the stack, move the stack out of view.
			// Keep contents through the close slide; notify after it.
			fakePopAnimation.duration = _animationDuration(operation)
			root.state = "closed"
		} else {
			// Off-screen pages may be destroyed by pop(); notify those now.
			// The visible page is notified in popExit (or immediately).
			_discardPagesUntil(discardToPage, root.currentItem)
			const adjusted = _adjustedStackOperation(operation)
			_poppedPage = root.pop(toPage, adjusted)
			if (adjusted === StackView.Immediate) {
				_finishPoppedPage()
			}
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
		_finishPoppedPage()
		_discardPagesUntil(null)
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
				id: fakePushSequence

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
				id: fakePopSequence

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
