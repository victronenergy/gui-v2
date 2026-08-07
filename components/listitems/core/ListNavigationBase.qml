/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A list setting item that leads to a sub-page when clicked, without any content.

	Extend this type, rather than ListNavigation, when you need to provide your own
	contentItem. Overriding the contentItem of ListNavigation would still construct
	ListNavigation's own contentItem, and its three labels and icon, only to throw
	it away: on a GX device that costs ~10ms per item.
*/
ListSetting {
	id: root

	property string secondaryText
	property color secondaryTextColor: Theme.color_listItem_secondaryText

	signal clicked

	function click() {
		// Just check 'interactive', and ignore 'userHasWriteAccess'. The control can be clicked
		// regardless of the write permission, since it opens a submenu instead of changing a value.
		if (interactive) {
			clicked()
		}
	}

	interactive: true
	hasSubMenu: interactive

	background: ListSettingBackground {
		color: root.flat ? "transparent" : Theme.color_listItem_background
		indicatorColor: root.backgroundIndicatorColor

		ListPressArea {
			anchors.fill: parent
			enabled: root.interactive
			onClicked: root.click()
		}
	}

	Keys.onSpacePressed: click()
	Keys.onRightPressed: click()
}
