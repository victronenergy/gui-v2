/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseListItem {
	id: root

	property alias spacing: contentColumn.spacing
	property alias leftPadding: contentColumn.leftPadding
	property alias rightPadding: contentColumn.rightPadding
	property alias topPadding: contentColumn.topPadding
	property alias bottomPadding: contentColumn.bottomPadding

	default property alias _data: contentColumn.data

	implicitWidth: contentColumn.implicitWidth
	implicitHeight: contentColumn.implicitHeight
	background.visible: false
	navigationHighlight.visible: false

	onActiveFocusChanged: {
		if (activeFocus) {
			keyNavHelper.initializeFocus()
		}
	}

	Keys.onUpPressed: (event) => {
		event.accepted = keyNavHelper.focusPreviousItem()
	}

	Keys.onDownPressed: (event) => {
		event.accepted = keyNavHelper.focusNextItem()
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
		spacing: Theme.geometry_gradientList_spacing
	}
}
