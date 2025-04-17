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
	// The number of items in the list (excluding header and footer)
	required property int itemCount

	// A function that returns the list item at the given index.
	required property var itemAtIndex

	// Header and footer items that can be navigated to by the user.
	property Item headerItem
	property Item footerItem

	// The current index, as selected by the user via key navigation.
	readonly property int currentIndex: _currentIndex

	property bool _receivedInitialFocus
	property int _currentIndex

	function resetCurrentIndex(index) {
		_currentIndex = index
	}

	// Focuses the header, or the first item in the list.
	function initializeFocus() {
		if (_receivedInitialFocus) {
			return false
		}
		_receivedInitialFocus = true
		if (Utils.acceptsKeyNavigation(headerItem)) {
			headerItem.focus = true
			return true
		} else {
			return focusNextItem(-1)
		}
	}

	// Moves the focus to the next item in the list.
	function focusNextItem(fromIndex) {
		if (footerItem?.activeFocus) {
			// If the footer is focused, then there is no item below to navigate to.
			return false
		}

		// Find the current index, or the index after the header if the header is focused.
		if (fromIndex === undefined) {
			fromIndex = headerItem?.activeFocus ? -1 : _currentIndex
		}
		// Move to the focus to the next focusable item.
		let nextIndex = fromIndex
		while (nextIndex < itemCount - 1) {
			nextIndex++
			const nextItem = itemAtIndex(nextIndex)
			if (!nextItem) {
				// There are no more created delegates, so stop searching.
				break
			}
			if (Utils.acceptsKeyNavigation(nextItem)) {
				_currentIndex = nextIndex

				// Move the focus away from the header if needed.
				if (!!headerItem?.activeFocus) {
					headerItem.focus = false
				}
				nextItem.focus = true
				return true
			}
		}
		// Allow key navigation to move into the footer.
		if (Utils.acceptsKeyNavigation(footerItem)) {
			footerItem.focus = true
			return true
		}
		return false
	}

	// Moves the focus to the previous item in the list.
	function focusPreviousItem(fromIndex) {
		if (headerItem?.activeFocus) {
			// If the header is focused, then there is no item above to navigate to.
			return false
		}

		// Find the current index, or the index above the footer if the footer is focused.
		if (fromIndex === undefined) {
			fromIndex = footerItem?.activeFocus ? itemCount : _currentIndex
		}
		// Move to the focus to the previous focusable item.
		let prevIndex = fromIndex
		while (prevIndex > 0) {
			prevIndex--
			const prevItem = itemAtIndex(prevIndex)
			if (!prevItem) {
				// There are no more created delegates, so stop searching.
				break
			}
			if (Utils.acceptsKeyNavigation(prevItem)) {
				// Move the current index.
				_currentIndex = prevIndex

				// Move the focus away from the footer if needed.
				if (!!footerItem?.activeFocus) {
					footerItem.focus = false
				}
				prevItem.focus = true
				return true
			}
		}
		// Allow key navigation to move into the header.
		if (Utils.acceptsKeyNavigation(headerItem)) {
			headerItem.focus = true
			return true
		}
		return false
	}
}
