/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A ListView, with key navigation support.

	Key navigation is supported between items if they pass the Utils.acceptsKeyNavigation() test.
	This includes header and footer items.

	Note: header and footer items should not exceed the ListView height. Otherwise, navigating to
	the start or end of the normal list items will cause adjacent list items to be obscured, as the
	list auto-scrolls to show the full header/footer. Also, key navigation within the header and
	footer does not auto-scroll the view.

	When the current item changes, the view auto-scrolls to show it, but only shows the start of an
	item that is larger than the view. To show the focused control inside such an item instead, set
	highlightFollowsCurrentItem to false, and call scrollToFocusedItem() when the focus moves inside
	the view.
*/
ListView {
	id: root

	readonly property KeyNavigationListHelper __keyNavHelper: keyNavHelper

	// Scrolls the view by the shortest distance that shows the item, which can be a delegate or an
	// item inside a delegate. If the item is larger than the view, shows the start of the item.
	function scrollToItem(item) {
		// Stop any scroll that is still running, as it could carry the item out of view again.
		cancelFlick()

		const horizontal = orientation === ListView.Horizontal
		const itemContentPos = contentItem.mapFromItem(item, 0, 0)
		const distance = horizontal
				? _scrollDistance(itemContentPos.x, item.width, contentX, width)
				: _scrollDistance(itemContentPos.y, item.height, contentY, height)
		if (distance === 0) {
			return
		}

		// A flick slows down from at most maximumFlickVelocity, so it can only scroll this far.
		const furthestFlick = maximumFlickVelocity * maximumFlickVelocity / (2 * flickDeceleration)
		const viewSize = horizontal ? width : height
		if (Math.abs(distance) > Math.min(viewSize * 2, furthestFlick)) {
			// The item is far away, or too far for a flick, so jump to it.
			if (horizontal) {
				contentX += distance
			} else {
				contentY += distance
			}
			returnToBounds()
		} else {
			// The item is close by, so just scroll to it.
			let velocity = Math.sqrt(2 * Math.abs(distance) * flickDeceleration)
			if (distance > 0) {
				velocity = -velocity
			}
			flick(horizontal ? velocity : 0, horizontal ? 0 : velocity)
		}
	}

	// Scrolls the view to show the delegate that contains the focused item. If the delegate is
	// larger than the view, shows the focused item instead.
	function scrollToFocusedItem(focusedItem) {
		let delegate = focusedItem
		while (delegate && delegate.parent !== contentItem) {
			delegate = delegate.parent
		}
		if (!delegate) {
			return
		}
		const delegateFits = orientation === ListView.Horizontal
				? delegate.width <= width
				: delegate.height <= height
		scrollToItem(delegateFits ? delegate : focusedItem)
	}

	function _scrollDistance(itemContentPos, itemSize, contentPos, viewSize) {
		if (itemContentPos + itemSize > contentPos + viewSize) {
			// Scroll right or scroll down, to show the end of the item. If the item is larger
			// than the view, show its start instead.
			return Math.min((itemContentPos + itemSize) - (contentPos + viewSize), itemContentPos - contentPos)
		} else if (itemContentPos < contentPos) {
			// Scroll left or scroll up (return a negative distance)
			return (itemContentPos - contentPos)
		} else {
			return 0
		}
	}

	function pageDown() {
		if ((orientation === Qt.Vertical && atYEnd) || (orientation === Qt.Horizontal && atXEnd)) {
			return false
		}

		forceLayout()
		const prevContentPos = _contentPos()
		if (orientation === Qt.Vertical) {
			contentY += height
		} else {
			contentX += width
		}
		returnToBounds()
		forceLayout()

		return prevContentPos !== _contentPos()
	}

	function _contentPos() {
		return orientation === Qt.Vertical ? contentY : contentX
	}

	width: parent?.width ?? 0
	height: parent?.height ?? 0
	orientation: ListView.Vertical
	boundsBehavior: Flickable.StopAtBounds
	maximumFlickVelocity: Theme.geometry_flickable_maximumFlickVelocity
	flickDeceleration: Theme.geometry_flickable_flickDeceleration
	highlightFollowsCurrentItem: true
	highlightMoveDuration: Theme.animation_listView_highlightMoveDuration
	focus: Global.keyNavigationEnabled

	// Disable the built-in navigation, and rely solely on key handling in KeyNavigationListHelper.
	// Otherwise, if the first/last items in the list fail Utils.acceptsKeyNavigation() during
	// navigation, the key event is passed up to the ListView, which will attempt to focus those
	// first/last items anyway (or failing those, the ListView itself).
	keyNavigationEnabled: false

	onCurrentIndexChanged: {
		// If the ListView current index is changed, update the navigation helper to use this same
		// index.
		keyNavHelper.resetCurrentIndex(currentIndex)
	}

	onActiveFocusChanged: {
		if (activeFocus && Global.keyNavigationEnabled) {
			keyNavHelper.updateFocusedItem()
		}
	}

	Keys.onUpPressed: (event) => event.accepted = orientation === Qt.Vertical ? keyNavHelper.focusPreviousItem() : false
	Keys.onDownPressed: (event) => event.accepted = orientation === Qt.Vertical ? keyNavHelper.focusNextItem() : false
	Keys.onLeftPressed: (event) => event.accepted = orientation === Qt.Horizontal ? keyNavHelper.focusPreviousItem() : false
	Keys.onRightPressed: (event) => event.accepted = orientation === Qt.Horizontal ? keyNavHelper.focusNextItem() : false
	Keys.enabled: Global.keyNavigationEnabled

	KeyNavigationListHelper {
		id: keyNavHelper

		itemCount: root.count
		itemAtIndex: (index) => {
			let item = root.itemAtIndex(index)
			if (!item && index >= 0 && index < count) {
				// itemAtIndex() will return null if the delegate at this index has not been created
				// (e.g. if scrolling too fast for delegate creation to keep up). Re-position the
				// view to force an update, and try again.
				root.positionViewAtIndex(index, ListView.Contain)
				item = root.itemAtIndex(index)
			 }
			 return item
		 }
		headerItem: root.headerItem
		footerItem: root.footerItem

		// Ensure view is auto-scrolled to keep the current index in view.
		onCurrentIndexChanged: root.currentIndex = currentIndex
		onScrollToStartRequested: root.positionViewAtBeginning()
		onScrollToEndRequested: root.positionViewAtEnd()
	}
}
