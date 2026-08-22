/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Handles the case where a text field is focused when running on Wasm, causing the native virtual
	keyboard (not the Qt virtual keyboard, as defined by InputPanel.qml) to appear. When this
	happens in landscape orientation, the view needs to move upwards or be scrolled upwards, so
	that the focused field is not obscured by the native VKB.
*/
Item {
	id: root

	property Item focusedItem
	property Flickable focusedView

	property real _initialViewBottomMargin
	property real _initialViewContentY

	function updateFocusItem(textField, view) {
		if (!textField || !view) {
			console.warn("update(): invalid item/view:", textField, view)
			return
		}

		if (state === "") {
			root._initialViewBottomMargin = view.bottomMargin
			root._initialViewContentY = view.contentY
		}

		root.focusedView = view
		root.focusedItem = textField

		if (root.state === "") {
			if (view.orientation === ListView.Vertical) {
				root.state = "scrollVertically"
			} else {
				root.state = "scrollHorizontally"
			}
		}
	}

	function reset() {
		// Note: do not clear focusedItem and focusedView as they may still be in use by the
		// PropertyChanges.
		root.state = ""
		root._initialViewBottomMargin = 0
		root._initialViewContentY = 0
	}

	function _distanceToScroll() {
		const textFieldBottom = Global.main.y
				+ Math.round(root.focusedItem.mapToItem(Global.main.contentItem, 0, root.focusedItem.height).y)
				+ Theme.geometry_inputPanel_topMargin
		return textFieldBottom - Theme.visualViewportBottom
	}

	// On Wasm on iOS, if the user clicks a text field within the VKB area, the VKB appears and the
	// contentY is scrolled to the correct position as expected. However, if the user then enters
	// some text, the HTML window's visualViewport auto-scrolls as if the VKB is not already open,
	// which moves the entire application UI upwards. To fix this, we could move the main window y
	// down by the window.visualViewport.offsetTop value, but this causes a visual stutter as the
	// UI jump upwards on the viewport scroll then immediately downwards for the correction. A
	// workaround that fixes this, surprisingly, is to re-click the text field after the initial
	// contentY adjustment.
	function _preventScrollOnIos() {
		UiConfig.mouseClick(root.focusedItem)
	}

	// Similarly to InputPanel.qml states:
	//
	// - For vertical list views (e.g. general settings list views, or Switch Pane in portrait):
	//   When a text field is focused, increase the view's bottomMargin to allow user to scroll to
	//   see content that would otherwise be hidden by the VKB, and adjust the view contentY to
	//   bring the field into view. Do not revert the contentY change when focus is lost, as the
	//   user may have scrolled the view to a new preferred contentY. Also, we prefer to change the
	//   bottomMargin rather than the view height, as changing the latter causes layout confusion
	//   when the contentY is also changed.
	//
	// - For horizontal list views (e.g. Switch Pane in landscape): When a text field is focused,
	//   scroll the view's contentY to force the field into view, and revert the contentY change
	//   when focus is lost, else the user cannot scroll to remove it in a horizontal list view.
	states: [
		State {
			name: "scrollVertically"

			PropertyChanges {
				target: root.focusedView
				bottomMargin: root._initialViewBottomMargin
					+ Math.max(0, Global.main.y + Global.main.height - Theme.visualViewportBottom)
			}

			// Theme.visualViewportBottom may change incrementally, so do not change the contentY
			// until the bottomMargin is updated, otherwise it will scroll to the wrong position.
			PropertyChanges {
				target: viewVerticalScroller
				enabled: true
			}
		},

		State {
			name: "scrollHorizontally"

			PropertyChanges {
				target: root.focusedView
				contentY: root._initialViewContentY + Math.max(0, root._distanceToScroll())
			}

			StateChangeScript {
				script: root._preventScrollOnIos()
			}
		}
	]

	Connections {
		id: viewVerticalScroller

		target: root.focusedView
		enabled: false

		function onBottomMarginChanged() {
			const delta = root._distanceToScroll()
			if (delta > 0) {
				contentYAnimation.to = root._initialViewContentY + delta
				verticalScrollAnimation.restart()
			}
		}
	}

	SequentialAnimation {
		id: verticalScrollAnimation

		NumberAnimation {
			id: contentYAnimation

			target: root.focusedView
			property: "contentY"
			duration: Global.animationEnabled ? Theme.animation_inputPanel_slide_duration : 0
		}

		ScriptAction {
			script: root._preventScrollOnIos()
		}
	}

	// Update the scroller when a text field is focused. We assume that a text field is focused if
	// the platform has opened the virtual keyboard while any item is focused.
	readonly property Item focusedInputCandidate: Theme.virtualKeyboardOpened ? Global.main.activeFocusItem : null
	onFocusedInputCandidateChanged: {
		if (focusedInputCandidate && focusedInputCandidate === focusListener.textField) {
			// User focused an item that is a text field; auto-scroll the view if needed.
			root.updateFocusItem(focusListener.textField, focusListener.viewToScroll)
		} else {
			// User focused an item that is not a text field; restore the values prior to the
			// focused state.
			root.reset()
			focusListener.textField = null
			focusListener.viewToScroll = null
		}
	}

	// Listen for the aboutToFocusTextField() signal. This allows gui-v2 to auto-scroll the
	// correct flickable when a text field in that flickable is focused.
	Connections {
		id: focusListener

		property Item textField
		property Flickable viewToScroll

		target: Global

		// Auto-scrolling in dialogs is handled by ModalDialog, so don't handle it here.
		enabled: !Global.dialogLayer.currentDialog

		// Called when a text field is pressed, before it receives focus.
		function onAboutToFocusTextField(textField, viewToScroll) {
			focusListener.textField = textField
			focusListener.viewToScroll = viewToScroll
		}
	}
}
