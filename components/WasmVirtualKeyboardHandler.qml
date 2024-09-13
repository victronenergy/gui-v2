/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// This handler increases the space below a flickable area whenever a text field within the
// flickable is focused, if the text field is near the bottom of the flickable, and would otherwise
// be obscured by the native virtual keyboard.
//
// This is required on Qt for Wasm on mobile browsers, as Qt.inputMethod does not provide the
// geometry of the native VKB in this instance (see QTBUG-128406) so it is not possible to resize
// and scroll flickables appropriately. So, the safest bet is to just scroll enough to show the
// text field at the very top of the flickable, as the native VKB may almost fill the entire screen
// on a mobile device in landscape orientation.
Item {
	id: root

	property var focusedFlickable
	property real initialBottomMargin
	property real initialCacheBuffer

	function acceptMouseEvent(item, itemMouseX, itemMouseY) {
		return false
	}

	function setFlickable(newFlickable) {
		// Restore the old flickable's original property values.
		if (focusedFlickable) {
			focusedFlickable.bottomMargin = initialBottomMargin
			focusedFlickable.cacheBuffer = initialCacheBuffer
			focusedFlickable = null
		}
		if (!newFlickable) {
			return
		}

		initialBottomMargin = newFlickable.bottomMargin
		initialCacheBuffer = newFlickable.cacheBuffer

		// Increase the cache buffer, otherwise the contentY jumps when changing focus between two
		// text fields that are far apart.
		newFlickable.bottomMargin = 0
		newFlickable.cacheBuffer = newFlickable.height * 2

		focusedFlickable = newFlickable
	}

	function updateFocusItem(textField, textFieldContainer, flickable) {
		// Whenever a text field is focused inside the flickable:
		// 1. Increase the bottomMargin of the flickable if this is necessary to allow the text
		//    field to be scrolled to the top of the viewport. (This ensures the native VKB does not
		//    obscure the text field, providing the VKB is anchored to the bottom of the screen and
		//    is not so high that it obscures almost the whole of the app UI.)
		// 2. Scroll the text field into view with a contentY animation.
		//
		// As a flickable is scrolled and text fields lower down in the flickable receive focus, the
		// bottomMargin is increased, as those fields will need more space below them to ensure the
		// VKB is visible.
		//
		// Note the bottomMargin is always increased, and never decreased. Otherwise, if the user
		// focuses a text field at the bottom of the flickable, then focuses another field higher up
		// in the flickable, then scrolls down without changing focus and without closing the VKB,
		// then the lower text field would no longer be visible, due to the shortened bottomMargin.
		//
		if (!textField || !textFieldContainer || !flickable) {
			console.warn("onAboutToFocusTextField(): invalid item/container/flickable:", textField, textFieldContainer, flickable)
			return
		}

		scrollAnimation.stop()
		if (flickable != root.focusedFlickable) {
			root.setFlickable(flickable)
		}

		// Find the position of the text field container within the flickable content item.
		const textContainerContentY = textFieldContainer.mapToItem(flickable.contentItem, 0, 0).y

		if (textContainerContentY + flickable.height > flickable.contentHeight) {
			// Find the distance that would be scrolled to place the text container at the top
			// of the content view.
			const jumpDistance = textFieldContainer.mapToItem(flickable, 0, 0).y

			// Set the bottomMargin to increase the scrollable height of the flickable. The
			// bottomMargin is never decreased, even if a shorter margin is sufficient.
			flickable.bottomMargin = Math.max(jumpDistance, flickable.bottomMargin)
		}

		scrollAnimation.target = flickable
		scrollAnimation.to = textContainerContentY
		scrollAnimation.start()
	}

	Connections {
		id: focusListener

		property var textField
		property var textFieldContainer
		property var flickable

		target: Global

		// Do not updateFocusItem() when this function is called, as that causes the flickable
		// scrolling to occur when a text field is pressed (rather than when released), which
		// produces confused scrolling behavior when dragging over a text field within the
		// flickable. Instead, record the parameters and call updateFocusItem() when the item
		// actually receives the focus (i.e. after the mouse is released).
		function onAboutToFocusTextField(textField, textFieldContainer, flickable) {
			focusListener.textField = textField
			focusListener.textFieldContainer = textFieldContainer
			focusListener.flickable = flickable
		}
	}

	Connections {
		target: Global.main

		function onActiveFocusItemChanged() {
			if (Global.main.activeFocusItem && Global.main.activeFocusItem === focusListener.textField) {
				updateFocusItem(focusListener.textField, focusListener.textFieldContainer, focusListener.flickable)
			}
		}
	}

	NumberAnimation {
		id: scrollAnimation
		properties: "contentY"
		duration: Theme.animation_inputPanel_slide_duration
	}

	Connections {
		target: root.focusedFlickable || null
		function onVisibleChanged() {
			// When the flickable disappears (e.g. when its parent page is popped) then restore its
			// original property values and stop tracking it.
			root.setFlickable(null)
		}
	}
}
