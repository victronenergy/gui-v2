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

	The index.html viewport fixes (visualViewport tracking + interactive-widget + 100lvh) keep the
	canvas pinned in place so Qt does not see a resize event when the keyboard opens. This means the
	focused field stays at its natural position near the bottom of the visible area above the
	keyboard, rather than being reflowed to the top.

	This handler therefore only scrolls when the focused field is actually outside the visible area:

	- When a text field is focused within the Control Cards or Switch Pane view, the cardsLoader is
	offset only if the field is hidden behind the status bar; otherwise no movement is applied.
	(If the mouse is pressed outside of the text field container item, the original position is
	restored.)

	- When a text field is focused within a flickable elsewhere in the UI, the flickable is scrolled
	just enough to show the field at the bottom of the viewport (above the keyboard), but only if
	the field is not already fully visible.
*/
Item {
	id: root

	property Flickable focusedFlickable
	property real initialBottomMargin
	property real initialCacheBuffer

	property Item focusedCardItem

	// Blocks the "already-focused" re-trigger paths in onAboutToFocusTextField for
	// 500 ms after Screen.heightChanged resets keyboard state, preventing Qt's internal
	// forceInputFocus()-during-resize from spuriously re-applying offsets.
	property bool _kbDismissGuard: false

	Timer {
		id: _kbDismissGuardTimer
		interval: 300
		onTriggered: root._kbDismissGuard = false
	}

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
		// Scroll just enough to show the focused text field at the bottom of the flickable
		// viewport (just above the keyboard), rather than scrolling it to the top.
		// Only scrolls at all if the field is currently outside the visible area.
		if (!textField || !textFieldContainer || !flickable) {
			console.warn("updateFocusItem(): invalid item/container/flickable:", textField, textFieldContainer, flickable)
			return
		}

		if (flickable != root.focusedFlickable) {
			root.setFlickable(flickable)
		}

		const textContainerContentY = textFieldContainer.mapToItem(flickable.contentItem, 0, 0).y
		const textContainerHeight = textFieldContainer.height
		const margin = Theme.geometry_page_content_verticalMargin

		// contentY that places the bottom of the field at the bottom of the viewport.
		const targetContentY = Math.max(0, textContainerContentY + textContainerHeight + margin - flickable.height)

		const fieldVisibleTop = textContainerContentY >= flickable.contentY
		const fieldVisibleBottom = textContainerContentY + textContainerHeight <= flickable.contentY + flickable.height
		if (fieldVisibleTop && fieldVisibleBottom) {
			return  // already fully visible, don't disturb the scroll position
		}

		// Ensure the flickable can be scrolled far enough to show the field at the bottom.
		const requiredHeight = textContainerContentY + textContainerHeight + margin
		if (requiredHeight > flickable.contentHeight) {
			flickable.bottomMargin = Math.max(flickable.bottomMargin,
					requiredHeight - flickable.contentHeight)
		}

		flickable.contentY = fieldVisibleBottom
				? textContainerContentY  // field is above viewport: scroll up to its top
				: targetContentY         // field is below viewport: scroll down to show bottom
	}

	Connections {
		target: Global

		// Called when a text field is pressed, before it receives focus.
		function onAboutToFocusTextField(textField, textFieldContainer, viewToScroll) {
			if (Qt.platform.os !== "wasm") {
				return
			}

			if (Global.currentDialog) {
				// If the text field is in a dialog, do not auto-scroll, as this will automatically
				// be done by the platform.
				return
			}

			if (viewToScroll === Global.mainView.cardsLoader) {
				// The text field is in the Control Cards or Switch Pane view.
				// Only offset the cardsLoader if the field is hidden behind the status bar;
				// otherwise leave it in place so it stays near the bottom of the visible area
				// above the keyboard rather than being moved to the top.
				const textContainerY = textFieldContainer.mapToItem(viewToScroll, 0, 0).y
				const topBound = Theme.geometry_statusBar_height + Theme.geometry_page_content_verticalMargin
				focusListener.cardLoaderOffset = textContainerY < topBound
						? topBound - textContainerY
						: 0
				focusedCardItem = textField
				// If the field already has focus (keyboard was dismissed but focus kept),
				// onActiveFocusItemChanged won't fire. Apply the offset directly —
				// but only outside the guard period (to skip Qt's internal re-focus).
				if (!root._kbDismissGuard && Global.main.activeFocusItem === textField) {
					Qt.callLater(() => {
						if (root.focusedCardItem === textField)
							Global.mainView.cardsLoader.setYOffset(focusListener.cardLoaderOffset, false)
					})
				}
			} else {
				// The text field is in a flickable in some other view. Delay the call to
				// updateFocusItem() until the onReleased event, to avoid confused scrolling
				// behavior when dragging over a text field within the view. Instead, record the
				// parameters and call the function later when the item actually receives the focus.
				focusListener.textField = textField
				focusListener.textFieldContainer = textFieldContainer
				focusListener.flickable = viewToScroll
				// Same "already focused" guard for the flickable case.
				if (!root._kbDismissGuard && Global.main.activeFocusItem === textField) {
					Qt.callLater(() => {
						if (focusListener.textField === textField)
							updateFocusItem(textField, textFieldContainer, viewToScroll)
					})
				}
			}
		}
	}

	Connections {
		id: focusListener

		property Item textField
		property Item textFieldContainer
		property Flickable flickable

		property real cardLoaderOffset

		target: Global.main

		function onActiveFocusItemChanged() {
			if (Global.main.activeFocusItem) {
				if (Global.main.activeFocusItem === root.focusedCardItem) {
					Global.mainView.cardsLoader.setYOffset(cardLoaderOffset, false)
				} else if (Global.main.activeFocusItem === textField) {
					updateFocusItem(textField, textFieldContainer, flickable)
				}
			} else if (!root._kbDismissGuard) {
				// Active focus cleared and we are not in the dismiss-guard window.
				// Reset all keyboard-adjusted positions so the UI returns to normal.
				if (!!root.focusedCardItem) {
					root.focusedCardItem = null
					Global.mainView.cardsLoader.clearYOffset()
				}
				root.setFlickable(null)
				textField = null
				textFieldContainer = null
				flickable = null
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

	// Detect native keyboard close via Theme.keyboardHeight, which is set from
	// JavaScript via Module.jsSetKeyboardHeight() (EMSCRIPTEN_BINDINGS in theme.cpp).
	// Screen.heightChanged does not fire for keyboard events on WASM, so that approach
	// was replaced by this direct C++→QML channel.
	property int _themeKbH: Theme.keyboardHeight
	on_ThemeKbHChanged: {
		if (Qt.platform.os !== "wasm" || _themeKbH > 0) return
		if (!!root.focusedCardItem) {
			root.focusedCardItem.focus = false
			root.focusedCardItem = null
			Global.mainView.cardsLoader.clearYOffset()
		}
		if (!!focusListener.textField) {
			focusListener.textField.focus = false
		}
		root.setFlickable(null)
		focusListener.textField = null
		focusListener.textFieldContainer = null
		focusListener.flickable = null
		root._kbDismissGuard = true
		_kbDismissGuardTimer.restart()
	}
}
