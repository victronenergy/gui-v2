/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListSettingBackground {
	required property ListSetting listItem
	readonly property alias mouseArea: mouseArea

	color: listItem.flat ? "transparent" : Theme.color_listItem_background
	indicatorColor: listItem.backgroundIndicatorColor

	// If button item is disabled due to write permissions, allow click to fall through to here
	// and show an error.
	MouseArea {
		id: mouseArea

		anchors.fill: parent
		enabled: !listItem.clickable && !listItem.userHasWriteAccess
		onClicked: listItem.checkWriteAccessLevel()
	}
}