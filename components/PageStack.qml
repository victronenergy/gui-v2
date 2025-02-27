/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

C.StackView {
	id: root

	property var pageUrls: []
	property Page _poppedPage

	readonly property bool animating: busy || fakePushAnimation.running || fakePopAnimation.running
	property bool swipeViewVisible: true

	// Slide new drill-down pages in from the right
	pushEnter: Transition {
		XAnimator {
			from: width
			to: 0
			duration: Theme.animation_page_slide_duration
			easing.type: Easing.InOutQuad
		}
	}

	pushExit: Transition {
		XAnimator {
			from: 0
			to: -width
			duration: Theme.animation_page_slide_duration
			easing.type: Easing.InOutQuad
		}
	}
	popEnter: Transition {
		XAnimator {
			from: -width
			to: 0
			duration: Theme.animation_page_slide_duration
			easing.type: Easing.InOutQuad
		}
	}

	popExit: Transition {
		SequentialAnimation {
			XAnimator {
				from: 0
				to: width
				duration: Theme.animation_page_slide_duration
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

	Connections {
		target: !!Global.pageManager ? Global.pageManager.emitter : null

		function onPagePushRequested(obj, properties, operation) {
			if (root.animating) {
				return
			}

			let objectOrUrl = typeof(obj) === "string" ? ".." + obj : obj
			if (typeof(obj) === "string") {
				// pre-construct the object to make sure there are no errors
				// to avoid messing up the page stack state.
				let checkComponent = Qt.createComponent(objectOrUrl)
				if (checkComponent.status !== Component.Ready) {
					console.warn("Aborted attempt to push page with errors: " + obj + ": " + checkComponent.errorString())
					return
				}
				objectOrUrl = checkComponent.createObject(null, properties)
				root.pageUrls.push(obj)
			} else {
				root.pageUrls.push("")
			}

			if (root.depth === 0) {
				// When the first page is added to the stack, move the stack into view.
				root.push(objectOrUrl, properties, C.StackView.Immediate)
				fakePushAnimation.duration = _animationDuration(operation)
				fakePushAnimation.start()
			} else {
				root.push(objectOrUrl, properties, _adjustedStackOperation(operation))
			}
		}

		function onPopAllPagesRequested(operation) {
			fakePopAnimation.duration = _animationDuration(operation)
			fakePopAnimation.start()
			root.pageUrls = []
		}

		function onPagePopRequested(toPage, operation) {
			if (root.animating
					|| (!!root.currentItem && !!root.currentItem.tryPop && !root.currentItem.tryPop())) {
				return
			}
			if (root.depth === 1) {
				// When the last page is removed from the stack, move the stack out of view.
				fakePopAnimation.duration = _animationDuration(operation)
				fakePopAnimation.start()
			} else {
				// Pop and delay destruction of the popped page until the animation completes,
				// otherwise the page disappears immediately.
				_poppedPage = root.pop(toPage, _adjustedStackOperation(operation))
			}
			root.pageUrls.pop()
		}

		function _animationDuration(operation) {
			return Global.allPagesLoaded && operation !== C.StackView.Immediate ? Theme.animation_page_slide_duration : 0
		}

		function _adjustedStackOperation(operation) {
			return Global.allPagesLoaded && operation !== C.StackView.Immediate ? operation : C.StackView.Immediate
		}
	}

	NumberAnimation {   // Cannot use XAnimator, it will abruptly reset the StackView x.
		id: fakePushAnimation

		onStopped: swipeViewVisible = false

		target: root
		property: "x"
		from: root.width
		to: 0
		easing.type: Easing.InOutQuad
	}

	NumberAnimation {   // Cannot use XAnimator, it will abruptly reset the StackView x.
		id: fakePopAnimation

		onStarted: swipeViewVisible = true
		onStopped: {
			// When leaving the page stack destroy all the pages
			while (root.depth > 1) {
				const page = root.pop(duration > 0 ? C.StackView.PopTransition : C.StackView.Immediate)
				if (page && !Theme.objectHasQObjectParent(page)) {
					page.destroy()
				}
			}

			// pop() only works for depth > 1
			const obj = root.currentItem
			root.clear()

			// Clean up the page object that was created on push.
			if (obj && !Theme.objectHasQObjectParent(obj)) {
				obj.destroy()
			}
		}

		target: root
		property: "x"
		from: 0
		to: root.width
		easing.type: Easing.InOutQuad
	}
}
