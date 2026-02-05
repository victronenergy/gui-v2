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
*/
ListView {
	id: root

	readonly property KeyNavigationListHelper __navHelper: keyNavHelper

	function pageDown() {
		if ((orientation === Qt.Vertical && atYEnd) || (orientation === Qt.Horizontal && atXEnd)) {
			return false
		}

		// Find the last item in the view and scroll so that it becomes the first item, unless it is
		// already the first item (i.e. if the item spans the whole screen width/height).
		const firstIndexInView = orientation === Qt.Vertical
				? indexAt(width / 2, contentY)
				: indexAt(contentX, height / 2)
		const lastIndexInView = orientation === Qt.Vertical
				? indexAt(width / 2, contentY + height)
				: indexAt(contentX + width, height / 2)
		const prevContentPos = _contentPos()
		if (lastIndexInView >= 0 && firstIndexInView !== lastIndexInView) {
			positionViewAtIndex(lastIndexInView, ListView.Beginning)
		}

		// If positionViewAtIndex() was not executed (e.g. if the item fills the whole list view,
		// or if indexAt() returned -1 because there's no more normal list items but there is a
		// footer and we need to scroll to it), or if positionViewAtIndex() didn't result in a
		// content pos change, then try again by directly changing the content pos.
		if (lastIndexInView < 0 || prevContentPos === _contentPos()) {
			if (orientation === Qt.Vertical) {
				contentY += height
			} else {
				contentX += width
			}
			returnToBounds()
		}

		return prevContentPos !== _contentPos()
	}

	function _contentPos() {
		return orientation === Qt.Vertical ? contentY : contentX
	}

	width: parent?.width ?? 0
	height: parent?.height ?? 0
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
