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

	Ideally this would only scroll the view up as much as is necessary to make space for the VKB,
	but Qt.inputMethod does not provide the geometry of the native VKB (see QTBUG-128406). So, the
	safest bet is to scroll enough to show the text field at the very top of the view, as the native
	VKB may almost fill the entire screen on a mobile device in landscape orientation.

	Two separate cases are handled:

	- When a text field is focused within the Control Cards or Switch Pane view, the view is moved
	upwards. (If the mouse is pressed outside of the text field container item, then the view's
	original position is restored. Ideally this would also be done when the native VKB was closed
	independently of the text field focus, but it is not possible to determine when this happens.)

	- When a text field is focused within a flickable elsewhere in the UI, the flickable is scrolled
	and space is added below it, if the text field would otherwise be obscured by the native VKB.
	(The original scroll position is not restored  when the mouse is pressed outside of the of the
	container, as the user may continue to scroll  through the view, and may choose to focus some
	other text field without wanting to make the VKB disappear and re-appear again.)
*/
Item {
	id: root

	property Flickable focusedFlickable
	property real initialBottomMargin
	property real initialCacheBuffer

	property Item focusedCardItem

	function acceptMouseEvent(item, itemMouseX, itemMouseY) {
		if (!!focusedCardItem) {
			const mappedPoint = focusedCardItem.mapFromItem(item, itemMouseX, itemMouseY)
			if (!focusedCardItem.contains(mappedPoint)) {
				// The screen was clicked outside of the text field. Remove focus from it, so that
				// the VKB will close. Return true to swallow the mouse event.
				focusedCardItem.focus = false
				focusedCardItem = null
				Global.mainView.cardsLoader.clearYOffset()
				return true
			}
		}
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
			console.warn("updateFocusItem(): invalid item/container/flickable:", textField, textFieldContainer, flickable)
			return
		}

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

		flickable.contentY = textContainerContentY
	}

	Connections {
		target: Global

		// Called when a text field is pressed, before it receives focus.
		function onAboutToFocusTextField(textField, textFieldContainer, viewToScroll) {
			if (!Theme.windowIsLandscape()) {
				return
			}

			if (viewToScroll === Global.mainView.cardsLoader) {
				// The text field is in the Control Cards or Switch Pane view. Find the position of
				// the text field container within the view, and move the view by this amount.
				// (Ideally this would not be done until the onReleased event, but in that case, on
				// the browser does not realise the text field is already in view, so when text is
				// entered into the field, the browser auto-shrinks the window, causing the field to
				// disappear from view.)
				const textContainerY = textFieldContainer.mapToItem(viewToScroll, 0, 0).y
				focusedCardItem = textField
				Global.mainView.cardsLoader.setYOffset(-textContainerY, false)
			} else {
				// The text field is in a flickable in some other view. Delay the call to
				// updateFocusItem() until the onReleased event, to avoid confused scrolling
				// behavior when dragging over a text field within the view. Instead, record the
				// parameters and call the function later when the item actually receives the focus.
				focusListener.textField = textField
				focusListener.textFieldContainer = textFieldContainer
				focusListener.flickable = viewToScroll
			}
		}
	}

	Connections {
		id: focusListener

		property Item textField
		property Item textFieldContainer
		property Flickable flickable

		target: Global.main

		function onActiveFocusItemChanged() {
			if (Global.main.activeFocusItem && Global.main.activeFocusItem === textField) {
				updateFocusItem(textField, textFieldContainer, flickable)
			}
		}
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
