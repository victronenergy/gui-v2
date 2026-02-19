/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

StackView {
	id: root

	readonly property bool opened: state === "opened" && !fakePushTransition.running
	readonly property Page currentPage: opened ? currentItem : null

	readonly property int animationDuration: Global.mainView && Global.mainView.allowPageAnimations ? Theme.animation_page_slide_duration : 0
	readonly property bool animating: busy || fakePushTransition.running || fakePopTransition.running

	// The file url of the top page on the stack. Undefined if depth=0 or not opened, or an empty
	// string if the top page is from a component (and so no url is available).
	property var topPageUrl: opened ? _topPageUrl : undefined

	property var _pageUrls: []
	property Page _poppedPage
	property var _topPageUrl

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

	function pushPage(obj, properties, operation) {
		if (root.animating) {
			return
		}
		if (state === "hidden") {
			// If the stack was hidden, it now contains pages that are no longer relevant. Clear all
			// pages on the stack, without changing the state to closed.
			_popAndDestroyAllPages(StackView.Immediate)
		}

		let objectOrUrl = typeof(obj) !== "string" ? obj
			: obj.indexOf("qrc:") === 0 ? obj
			: ".." + obj
		if (typeof(obj) === "string") {
			// pre-construct the object to make sure there are no errors
			// to avoid messing up the page stack state.
			let checkComponent = Qt.createComponent(objectOrUrl)
			if (checkComponent.status !== Component.Ready) {
				console.warn("Aborted attempt to push page with errors: " + obj + ": " + checkComponent.errorString())
				return
			}
			objectOrUrl = checkComponent.createObject(null, properties)
			root._pageUrls.push(obj)
			root._topPageUrl = obj
		} else {
			root._pageUrls.push("")
			root._topPageUrl = ""
		}

		if (root.depth === 0) {
			// When the first page is added to the stack, move the stack into view.
			root.push(objectOrUrl, properties, StackView.Immediate)
			fakePushAnimation.duration = _animationDuration(operation)
			root.state = "opened"
		} else {
			root.push(objectOrUrl, properties, _adjustedStackOperation(operation))
		}
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
	x: Global.screenWidth
	width: Global.screenWidth
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

			NumberAnimation {   // Cannot use XAnimator, it will abruptly reset the StackView x.
				id: fakePushAnimation
				property: "x"
				easing.type: Easing.InOutQuad
			}
		},
		Transition {
			id: fakePopTransition

			from: "opened"

			SequentialAnimation {
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
