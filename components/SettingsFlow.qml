/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// TODO, ideally make a C++ Flow-based type that is a focus scope, instead of making a QML type here
// and redirecting the children using a default property alias.
FocusScope {
	id: root

	// Allow the flow to be filtered out by VisibleItemModel, similar to an AbstractListItem.
	property bool preferredVisible: true
	property bool effectiveVisible: preferredVisible

	property alias spacing: contentFlow.spacing
	property alias leftPadding: contentFlow.leftPadding
	property alias rightPadding: contentFlow.rightPadding
	property alias topPadding: contentFlow.topPadding
	property alias bottomPadding: contentFlow.bottomPadding

	readonly property KeyNavigationListHelper __keyNavHelper: keyNavHelper
	default property alias _data: contentFlow.data

	implicitWidth: contentFlow.implicitWidth
	implicitHeight: contentFlow.implicitHeight

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

		itemCount: contentFlow.children.length
		itemAtIndex: (index) => {
			return contentFlow.children[index]
		}
	}

	Flow {
		id: contentFlow
		width: parent.width
		height: parent.height
	}
}
