/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides key navigation for a list of items, which may include a header and footer.
  */
QtObject {
	id: root

	// The number of items in the list (excluding header and footer)
	required property int itemCount

	// A function that returns the list item at the given index.
	required property var itemAtIndex

	// Header and footer items that can be navigated to by the user.
	property Item headerItem
	property Item footerItem

	// The current index, as selected by the user via key navigation.
	readonly property int currentIndex: _currentIndex

	property bool _initialized
	property int _currentIndex

	signal scrollToStartRequested()
	signal scrollToEndRequested()

	function resetCurrentIndex(index) {
		_currentIndex = index
	}

	function updateFocusedItem() {
		const validCurrentIndex = _currentIndex >= 0 && _currentIndex < itemCount
		const currentItem = _initialized && validCurrentIndex ? itemAtIndex(currentIndex) : null

		// If no items have been focused yet, or the previously focused item can no longer be
		// focused, then find a new item to focus.
		if (!currentItem || !Utils.acceptsKeyNavigation(currentItem)) {
			if (_initialized && validCurrentIndex) {
				// The current item is no longer focusable, so find a focusable item, working
				// backwards from the current index.
				if (focusPreviousItem(currentIndex)) {
					return
				}
			}
			// Focus the first available item.
			_initialized = true
			if (Utils.acceptsKeyNavigation(headerItem)) {
				headerItem.focus = true
			} else {
				focusNextItem(-1)
			}
		}
	}

	// Moves the focus to the next item in the list.
	function focusNextItem(fromIndex) {
		return _moveFocus(fromIndex, true)
	}

	// Moves the focus to the previous item in the list.
	function focusPreviousItem(fromIndex) {
		return _moveFocus(fromIndex, false)
	}

	// Focuses the next item (fromIndex + 1) or previous item (fromIndex - 1).
	// If fromIndex is not set, then the currentIndex is used.
	function _moveFocus(fromIndex, forward) {
		if ((forward && footerItem?.activeFocus) || (!forward && headerItem?.activeFocus)) {
			// If moving forward and the footer is already focused, or moving backward and the
			// header is already focused, then the user has reached the end of the list.
			return false
		}

		if (fromIndex === undefined) {
			// Start from the currentIndex, or from before or after the header/footer if one of
			// those are focused.
			const invalidCurrentIndex = _currentIndex < 0 || _currentIndex >= itemCount
			if (forward) {
				fromIndex = invalidCurrentIndex || headerItem?.activeFocus ? -1 : _currentIndex
			} else {
				fromIndex = invalidCurrentIndex || footerItem?.activeFocus ? itemCount : _currentIndex
			}
		}

		// Move to the focus to the next/previous focusable item.
		for (let toIndex = forward ? fromIndex + 1 : fromIndex - 1;
					forward ? toIndex < itemCount : toIndex >= 0;
					forward ? ++toIndex : --toIndex) {
			const toItem = itemAtIndex(toIndex)
			if (!toItem) {
				// There are no more created delegates, so stop searching.
				break
			}
			if (Utils.acceptsKeyNavigation(toItem)) {
				_currentIndex = toIndex

				// If moving away from a header/footer that is focused, remove the focus.
				if (forward && headerItem?.activeFocus) {
					headerItem.focus = false
				} else if (!forward && footerItem?.activeFocus) {
					footerItem.focus = false
				}
				toItem.focus = true
				return true
			}
		}

		// Allow key navigation to move to the footer (if moving forwards) or footer (if backwards).
		if (forward && Utils.acceptsKeyNavigation(footerItem)) {
			footerItem.focus = true
			return true
		} else if (!forward && Utils.acceptsKeyNavigation(headerItem)) {
			headerItem.focus = true
			return true
		}

		// If there are more items but they are not focusable, ensure these items are visible
		// before the focus moves outside of the list, else those items may remain hidden.
		if (forward) {
			if (_currentIndex < itemCount - 1 || footerItem) {
				scrollToEndRequested()
			}
		} else if (_currentIndex > 0 || headerItem) {
			scrollToStartRequested()
		}

		return false
	}
}
