/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property alias text: primaryLabel.text
	property alias content: content
	property bool down
	property alias backgroundRect: backgroundRect
	property int spacing: Theme.geometry.settingsPage.settingsList.spacing

	property int showAccessLevel: VenusOS.User_AccessType_User
	property int writeAccessLevel: VenusOS.User_AccessType_User
	readonly property bool userHasWriteAccess: Global.systemSettings.accessLevel >= writeAccessLevel

	readonly property bool defaultVisible: Global.systemSettings.accessLevel >= showAccessLevel

	width: parent ? parent.width : 0
	implicitHeight: visible ? backgroundRect.height + spacing : 0
	visible: defaultVisible
	enabled: userHasWriteAccess

	Rectangle {
		id: backgroundRect

		width: root.width
		height: Math.max(primaryLabel.height + Theme.geometry.settingsListItem.content.verticalMargin * 2,
				Theme.geometry.settingsListItem.height)
		radius: Theme.geometry.settingsListItem.radius
		color: root.down ? Theme.color.settingsListItem.down.background : Theme.color.settingsListItem.background
	}

	Label {
		id: primaryLabel

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.settingsListItem.content.leftMargin
			right: content.left
			rightMargin: Theme.geometry.settingsListItem.content.spacing
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: -root.spacing/2
		}
		font.pixelSize: Theme.font.size.body2
		wrapMode: Text.Wrap
	}

	Row {
		id: content

		anchors {
			right: parent.right
			rightMargin: Theme.geometry.settingsListItem.content.rightMargin
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: -root.spacing/2
		}
		spacing: Theme.geometry.settingsListItem.content.spacing
	}
}
