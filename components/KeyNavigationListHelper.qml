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
		if (!currentItem || !_focusContainerOrItem(currentItem)) {
			if (_initialized && validCurrentIndex) {
				// The current item is no longer focusable, so find a focusable item, working
				// backwards from the current index.
				if (focusPreviousItem(currentIndex)) {
					return true
				}
			}
			// Focus the first available item.
			_initialized = true
			if (_focusContainerOrItem(headerItem)) {
				headerItem.focus = true
				_currentIndex = -1
				return true
			} else {
				return focusNextItem(-1)
			}
		}
		return _currentIndex >= 0 && _currentIndex < itemCount
	}

	// Moves the focus to the next item in the list.
	function focusNextItem(fromIndex) {
		return _moveFocus(fromIndex, true)
	}

	// Moves the focus to the previous item in the list.
	function focusPreviousItem(fromIndex) {
		return _moveFocus(fromIndex, false)
	}

	// Moves focus to a view or item. If a view with a KeyNavigationListHelper is specified, returns
	// the result of calling updateFocusedItem() on that view, so that the caller can determine
	// whether the focus was moved sucessfully - e.g. it will fail if the view currently has no
	// focusable items, and in that case the caller can try a different item.
	// If a non-view is specified, this simply sets focus=true on the item.
	function _focusContainerOrItem(containerOrItem) {
		if (!Utils.acceptsKeyNavigation(containerOrItem)) {
			return false
		}
		if (containerOrItem.__keyNavHelper) {
			// Try to focus the first item in the container.
			return containerOrItem.__keyNavHelper.updateFocusedItem()
		} else {
			// Focus the item.
			containerOrItem.focus = true
			return true
		}
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

			if (_focusContainerOrItem(toItem)) {
				_currentIndex = toIndex
				return true
			}
		}

		// Allow key navigation to move to the footer (if moving forwards) or footer (if backwards).
		if (forward && _focusContainerOrItem(footerItem)) {
			footerItem.focus = true
			_currentIndex = -1
			scrollToEndRequested() // ensure footer can be seen
			return true
		} else if (!forward && _focusContainerOrItem(headerItem)) {
			headerItem.focus = true
			_currentIndex = -1
			scrollToStartRequested() // ensure header can be seen
			return true
		}

		// If there are more items but they are not focusable, ensure these items can be seen
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
