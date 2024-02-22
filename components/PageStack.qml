/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

C.StackView {
	id: root

	property Page _poppedPage

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

		function onPagePushRequested(obj, properties) {
			if (root.busy) {
				return
			}

			let objectOrUrl = typeof(obj) === "string" ? Global.appUrl(obj) : obj
			if (typeof(obj) === "string") {
				// pre-construct the object to make sure there are no errors
				// to avoid messing up the page stack state.
				let checkComponent = Qt.createComponent(objectOrUrl)
				if (checkComponent.status !== Component.Ready) {
					console.warn("Aborted attempt to push page with errors: " + obj + ": " + checkComponent.errorString())
					return
				}
				objectOrUrl = checkComponent.createObject(null, properties)
			}

			if (root.depth === 0) {
				// When the first page is added to the stack, slide the stack into view.
				root.push(objectOrUrl, properties, PageStack.Immediate)
				fakePushAnimation.start()
			} else {
				root.push(objectOrUrl, properties)
			}
		}

		function onPagePopRequested(toPage) {
			if (root.busy
					|| (!!root.currentItem.tryPop && !root.currentItem.tryPop())) {
				return
			}
			if (root.depth === 1) {
				// When the last page is removed from the stack, slide the stack out of view.
				fakePopAnimation.start()
			} else {
				// Pop and delay destruction of the popped page until the animation completes,
				// otherwise the page disappears immediately.
				_poppedPage = pop(toPage)
			}
		}
	}

	NumberAnimation {   // Cannot use XAnimator, it will abruptly reset the StackView x.
		id: fakePushAnimation

		target: root
		property: "x"
		from: root.width
		to: 0
		duration: Theme.animation_page_slide_duration
		easing.type: Easing.InOutQuad
	}

	SequentialAnimation {
		id: fakePopAnimation

		NumberAnimation {   // Cannot use XAnimator, it will abruptly reset the StackView x.
			target: root
			property: "x"
			from: 0
			to: root.width
			duration: Theme.animation_page_slide_duration
			easing.type: Easing.InOutQuad
		}
		ScriptAction {
			script: {
				const obj = root.currentItem
				root.clear()

				// Clean up the page object that was created on push.
				if (!Theme.objectHasQObjectParent(obj)) {
					obj.destroy()
				}
			}
		}
	}
}
