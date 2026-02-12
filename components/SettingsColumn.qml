/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FocusScope {
	id: root

	// Allow the column to be filtered out by VisibleItemModel, similar to an AbstractListItem.
	property bool preferredVisible: true
	property bool effectiveVisible: preferredVisible

	property alias spacing: contentColumn.spacing
	property alias leftPadding: contentColumn.leftPadding
	property alias rightPadding: contentColumn.rightPadding
	property alias topPadding: contentColumn.topPadding
	property alias bottomPadding: contentColumn.bottomPadding

	default property alias _data: contentColumn.data

	implicitWidth: contentColumn.implicitWidth
	implicitHeight: contentColumn.implicitHeight

	// Allow Utils.acceptsKeyNavigation() to accept moving focus to this item.
	focusPolicy: effectiveVisible ? Qt.TabFocus : Qt.NoFocus
	focus: true

	Keys.onUpPressed: (event) => event.accepted = keyNavHelper.focusPreviousItem()
	Keys.onDownPressed: (event) => event.accepted = keyNavHelper.focusNextItem()
	Keys.enabled: Global.keyNavigationEnabled

	onActiveFocusChanged: {
		if (activeFocus && Global.keyNavigationEnabled) {
			keyNavHelper.updateFocusedItem()
		}
	}

	KeyNavigationListHelper {
		id: keyNavHelper

		itemCount: contentColumn.children.length
		itemAtIndex: (index) => {
			return contentColumn.children[index]
		}
	}

	Column {
		id: contentColumn
		width: parent.width
		height: parent.height
		spacing: Theme.geometry_gradientList_spacing
	}
}
