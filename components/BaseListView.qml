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

	width: parent?.width ?? 0
	height: parent?.height ?? 0
	boundsBehavior: Flickable.StopAtBounds
	maximumFlickVelocity: Theme.geometry_flickable_maximumFlickVelocity
	flickDeceleration: Theme.geometry_flickable_flickDeceleration
	highlightFollowsCurrentItem: true
	highlightMoveDuration: Theme.animation_listView_highlightMoveDuration
	focus: true

	onActiveFocusChanged: {
		if (activeFocus) {
			keyNavHelper.initializeFocus()
		}
	}

	Keys.onUpPressed: (event) => {
		event.accepted = orientation === Qt.Vertical ? keyNavHelper.focusPreviousItem() : false
	}
	Keys.onDownPressed: (event) => {
		event.accepted = orientation === Qt.Vertical ? keyNavHelper.focusNextItem() : false
	}
	Keys.onLeftPressed: (event) => {
		event.accepted = orientation === Qt.Horizontal ? keyNavHelper.focusPreviousItem() : false
	}
	Keys.onRightPressed: (event) => {
		event.accepted = orientation === Qt.Horizontal ? keyNavHelper.focusNextItem() : false
	}

	KeyNavigationListHelper {
		id: keyNavHelper

		itemCount: root.count
		itemAtIndex: (index) => root.itemAtIndex(index)
		headerItem: root.headerItem
		footerItem: root.footerItem

		// Ensure view is auto-scrolled to keep the current index in view.
		onCurrentIndexChanged: root.currentIndex = currentIndex
	}
}
