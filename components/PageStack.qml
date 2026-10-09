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
	readonly property bool animating: busy || fakePushTransition.running || fakePopTransition.running

	// The file url of the top page on the stack. Undefined if depth=0 or not opened, or an empty
	// string if the top page is from a component (and so no url is available).
	property var topPageUrl: opened ? _topPageUrl : undefined

	property var _pageUrls: []
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

	// Destroy a page created with createObject(null). StackView-parented
	// pages are destroyed by the stack; do not destroy those here.
	// Do not emit aboutToBeDiscarded again. The Page handler flag does not
	// stop BaseListView or ObjectModelMonitor subscribers.
	function _destroyUnparentedPage(page) {
		if (!page || Theme.objectHasQObjectParent(page)) {
			return
		}
		if (page.aboutToBeDiscarded && !page._discardNotified) {
			page.aboutToBeDiscarded()
		}
		page.destroy()
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

	function pushPage(obj, properties, operation) {
		if (root.animating) {
			return null
		}
		if (state === "hidden") {
			// If the stack was hidden, it now contains pages that are no longer relevant. Clear all
			// pages on the stack, without changing the state to closed.
			_popAndDestroyAllPages(StackView.Immediate)
		}

		const pageUrl = typeof(obj) === "string" ? obj : ""
		let objectOrUrl = typeof(obj) !== "string" ? obj
			: obj.indexOf("qrc:") === 0 ? obj
			: ".." + obj
		let createdPageObject = null
		if (typeof(obj) === "string") {
			// pre-construct the object to make sure there are no errors
			// to avoid messing up the page stack state.
			let checkComponent = Qt.createComponent(objectOrUrl)
			if (checkComponent.status !== Component.Ready) {
				console.warn("Aborted attempt to push page with errors: " + obj + ": " + checkComponent.errorString())
				return null
			}
			createdPageObject = checkComponent.createObject(null, properties)
			if (!createdPageObject) {
				console.warn("Aborted attempt to push page because createObject() failed: " + obj + ": " + checkComponent.errorString())
				return null
			}
			objectOrUrl = createdPageObject
		}

		let pushedPage = null
		if (root.state !== "opened") {
			// When the stack is closed or hidden, push the first page without any animation and
			// slide the stack into view.
			pushedPage = root.push(objectOrUrl, properties, StackView.Immediate)
			if (!pushedPage) {
				_destroyUnparentedPage(createdPageObject)
				console.warn("Aborted attempt to push page because StackView rejected the page object: " + pageUrl)
				return null
			}
			root._pageUrls.push(pageUrl)
			root._topPageUrl = pageUrl
			fakePushAnimation.duration = _animationDuration(operation)
			root.state = "opened"
		} else {
			// Otherwise, push the push onto the visible stack, possibly with an animation.
			pushedPage = root.push(objectOrUrl, properties, _adjustedStackOperation(operation))
			if (!pushedPage) {
				_destroyUnparentedPage(createdPageObject)
				console.warn("Aborted attempt to push page because StackView rejected the page object: " + pageUrl)
				return null
			}
			root._pageUrls.push(pageUrl)
			root._topPageUrl = pageUrl
		}
		return pushedPage
	}

	function popAllPages(operation) {
		if (!_canPopTo(null)) {
			return
		}
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
		if (animating || state === "opened" || depth === 0) {
			return false
		}
		fakePushAnimation.duration = _animationDuration(StackView.PushTransition)
		state = "opened"
		return true
	}

	function hide() {
		if (animating || state !== "opened") {
			return false
		}
		fakePopAnimation.duration = _animationDuration(StackView.PopTransition)
		state = "hidden"
		return true
	}

	function _popAndDestroyAllPages(operation) {
		_finishPoppedPage()
		_discardPagesUntil(null)
		root._pageUrls = []
		root._topPageUrl = undefined

		while (root.depth > 1) {
			const page = root.pop(operation)
			_destroyUnparentedPage(page)
		}

		// pop() only works for depth > 1
		const obj = root.currentItem
		root.clear()

		// Clean up the page object that was created in pushPage().
		_destroyUnparentedPage(obj)
	}

	function _canPopTo(toPage) {
		if (root.animating
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
