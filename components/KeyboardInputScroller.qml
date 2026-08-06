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

	property Item focusedItem
	property Flickable focusedView

	property real _initialViewHeight
	property real _initialViewContentY

	function update(textField, view) {
		if (!textField || !view) {
			console.warn("update(): invalid item/view:", textField, view)
			return
		}

		if (state === "") {
			_initialViewHeight = view.height
			_initialViewContentY = view.contentY
		}
		root.focusedView = view
		root.focusedItem = textField

		// If the Flickable is a vertical ListView, then apply vertical scrolling behaviour;
		// otherwise for horizontal ListViews or generic flickables, use the horizontal scrolling
		// behaviour.
		state = view.orientation === ListView.Vertical ? "scrollVertically" : "scrollHorizontally"
	}

	function deactivate() {
		state = ""
	}

	states: [
		// For vertical list views (e.g. general settings list views, or Switch Pane in portrait):
		//
		//  - When a text field is focused, shrink the view height to allow the user to see content at
		//    the bottom of the view that would otherwise be hidden by the VKB, and if needed, also
		//    scroll the contentY to bring the field into view.
		//
		//  - When focus is lost, restore the previous view height, but do not restore the contentY as
		//    this makes the view visually quite jumpy, and also if the user has scrolled the view to a
		//    new preferred contentY this would moves the user's view away from the preferred position.
		State {
			name: "scrollVertically"

			PropertyChanges {
				target: root.focusedView
				height: root._initialViewHeight - Math.max(0, Global.itemDistanceToVKB(root.focusedView, root._initialViewHeight, Global.main.contentItem))

				// In case the platform shows the VKB in a partially transparent manner (e.g. on
				// iOS), increase the ListView display margin so that delegates below the view (i.e.
				// in the VKB area) are still rendered. Otherwise, the ListView automatically
				// creates/destroys delegates in this area and the user will see them appear/
				// disappear while scrolling.
				// Note: only ListView types have displayMarginEnd, so if the view is a generic
				// Flickable, this will produce a warning.
				displayMarginEnd: Theme.keyboardHeight
			}

			// To scroll the contentY, activate the verticalViewScroller instead of changing the
			// contentY property directly here; otherwise, the contentY will change as soon as the
			// state is entered, which results in the wrong contentY being applied. Instead, we
			// must wait until height changes are applied by the other PropertyChanges before
			// updating the contentY, so use a Connections object to detect this.
			PropertyChanges {
				verticalViewScroller.enabled: true
			}
		},

		// For horizontal list views (e.g. Switch Pane in landscape):
		//
		//  - When a text field is focused, scroll the contentY to bring the field into view. (This
		//    works even for horizontal-scrolling ListViews, as the Flickable just create the empty
		//    space in the view as needed.) Do not shrink the view height as this would collapse
		//    the area available to ListView delegates.
		//
		//  - When focus is lost, restore the contentY, otherwise the empty space remains and the
		//    user also cannot scroll to remove it (as the list view only scrolls horizontally).
		State {
			name: "scrollHorizontally"

			PropertyChanges {
				target: root.focusedView
				contentY: root._initialViewContentY + Math.max(0, Global.itemDistanceToVKB(root.focusedItem, root.focusedItem.height, Global.main.contentItem))
			}
		}
	]

	// Note: Do not run transitions for the PropertyChanges. The continuous keyboardHeight changes
	// cause continous updates to the view height, and animating these changes causes incorrect
	// height values.

	Connections {
		id: verticalViewScroller

		target: root.focusedView
		enabled: false

		function onHeightChanged() {
			// Once the view height has updated, scroll the flickable upwards to show the text field
			// above the VKB.
			const delta = Global.itemDistanceToVKB(root.focusedItem, root.focusedItem.height, Global.main.contentItem)
			if (delta > 0) {
				if (Global.isGxDevice && Global.animationEnabled) {
					// On GX, animate the contentY using the same duration/easing parameters as the
					// appearance of the VKB, as implemented by InputPanel.qml.
					contentYAnimation.to = root._initialViewContentY + delta
					contentYAnimation.start()
				} else {
					// Otherwise, jump to the new contentY immediately.
					root.focusedView.contentY = root._initialViewContentY + delta
				}
			}
		}
	}

	NumberAnimation {
		id: contentYAnimation

		target: root.focusedView
		property: "contentY"
		duration: Theme.animation_inputPanel_slide_duration
		easing.type: Easing.InOutQuad
	}

	readonly property Item activeInputItem: Theme.keyboardHeight > 0 ? Global.main.activeFocusItem : null
	onActiveInputItemChanged: {
		if (activeInputItem && activeInputItem === focusListener.textField) {
			root.update(focusListener.textField, focusListener.viewToScroll)
		} else if (root.state !== "") {
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
