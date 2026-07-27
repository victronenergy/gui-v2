/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Scrolls and adjusts a flickable to make a focused child text field visible above the VKB.

	When a text field is focused (as indicated by Global.main.activeFocusItem and the
	Global.aboutToFocusTextField() signal), the virtual keyboard (either the Qt VKB on GX, or the
	native system VKB on Wasm) appears. To prevent this VKB from obfuscating the currently focused
	text field, this component adjusts the properties of the text field's parent flickable to ensure
	the field is visible.
*/
Item {
	id: root

	property Flickable focusedView

	property real _toViewContentY
	property real _toViewHeight
	property real _initialViewHeight

	function update(textField, view) {
		if (!textField || !view) {
			console.warn("update(): invalid item/view:", textField, view)
			return
		}

		if (state !== "active") {
			_toViewContentY = 0
			_toViewHeight = 0
			_initialViewHeight = view.height
		}
		root.focusedView = view

		const delta = UiConfig.itemBottomDistanceToVKB(textField)
		if (delta > 0) {
			// Scroll the flickable upwards to show the item above the VKB. (For the cards view in
			// landscape, this forces the view upwards to make space for the VKB.)
			root._toViewContentY = view.contentY + delta
		} else {
			root._toViewContentY = view.contentY
		}

		// For vertical list views, shrink the view height to allow the user to see content at the
		// bottom of the view that would otherwise be hidden by the VKB. Do not do this for
		// horizontally-oriented views (e.g. the Control Cards in landscape layout) as it would
		// cause the view to be collapsed to follow the adjusted height, whereas for vertically
		// oriented views, it would only reduce the scrollable area.
		if (view.orientation === ListView.Vertical) {
			const viewDeltaToVKB = UiConfig.itemBottomDistanceToVKB(view)
			root._toViewHeight = root._initialViewHeight - Math.max(0, viewDeltaToVKB)
		} else {
			root._toViewHeight = root._initialViewHeight
		}

		state = "active"
	}

	function deactivate() {
		state = ""
	}

	states: [
		State {
			name: "active"

			PropertyChanges {
				target: root.focusedView
				height: root._toViewHeight

				// In case the platform shows the VKB in a partially transparent manner (e.g. on
				// iOS), increase the ListView display margin so that delegates below the view (i.e.
				// in the VKB area) are still rendered. Otherwise, the ListView automatically
				// creates/destroys delegates in this area and the user will see them appear/
				// disappear while scrolling.
				// Note: only ListView types have displayMarginEnd, so if the view is a generic
				// Flickable, this will produce a warning.
				displayMarginEnd: Theme.keyboardHeight

				// Do not update the values after the initial property change, otherwise the view
				// height flickers when selecting consecutive text fields in the same view. There is
				// no need to update it after the initial change anyway.
				explicit: true
			}

			PropertyChanges {
				target: root.focusedView
				contentY: root._toViewContentY

				// The user may scroll the flickable (thus changing the contentY) while the text
				// field is focused, so do not revert the contentY (and thus change from the user's
				// preferred contentY) when the VKB closes.
				// The exception is when the VKB is shown for the cards view in landscape, where the
				// contentY change from the auto-scroll behaviour actually displaces the entire view
				// upwards (instead of just scrolling it), so when the VKB closes, revert to the
				// view's original position.
				restoreEntryValues: root.focusedView === Global.mainView.cardsLoader.cardViewFlickable
						&& Theme.screenSize !== Theme.Portrait
			}
		}
	]

	transitions: [
		Transition {
			// Do not animate property changes for regular list views on Wasm, as the
			// GradientListView's bottom gradient visually stutters because Theme.keyboardHeight
			// does not change until the native VKB is fully opened.
			// In the Switch Pane, it is fine to animate the changes as there is no bottom gradient.
			// And on the GX, the changes can be animated because the height animates with the same
			// duration (Theme.animation_inputPanel_slide_duration) as that of the Qt VKB slide
			// in/out animation, as implemented in InputPanel.qml.
			enabled: Global.isGxDevice
					|| root.focusedView === Global.mainView.cardsLoader.cardViewFlickable

			NumberAnimation {
				properties: "contentY,height,displayMarginEnd"
				duration: Theme.animation_inputPanel_slide_duration
				easing.type: Easing.InOutQuad
			}
		}
	]

	readonly property Item activeInputItem: Theme.keyboardHeight > 0 ? Global.main.activeFocusItem : null
	onActiveInputItemChanged: {
		if (activeInputItem && activeInputItem === focusListener.textField) {
			root.update(focusListener.textField, focusListener.viewToScroll)
		} else if (root.state === "active") {
			root.deactivate()
			if (focusListener.textField) {
				// Forcibly remove focus from the old field. Otherwise, if you go into a sub-page
				// and back, the field still has focus and the VKB opens again.
				focusListener.textField.focus = false
			}
			focusListener.viewToScroll = null
			focusListener.textField = null
		}
	}

	Connections {
		id: focusListener

		property Item textField
		property Flickable viewToScroll

		function onAboutToFocusTextField(textField, viewToScroll) {
			if (!viewToScroll) {
				// If the text field is not inside a flickable, ignore this.
				return
			}
			focusListener.viewToScroll = viewToScroll
			focusListener.textField = textField
		}

		target: Global
	}
}
