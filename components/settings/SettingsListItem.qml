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
	readonly property bool userHasWriteAccess: Global.systemSettings.accessLevel.value !== undefined
			&& Global.systemSettings.accessLevel.value >= writeAccessLevel

	readonly property bool defaultVisible: Global.systemSettings.accessLevel.value !== undefined
			&& Global.systemSettings.accessLevel.value >= showAccessLevel

	implicitWidth: parent ? parent.width : 0
	implicitHeight: visible
		? Math.max(primaryLabel.implicitHeight + Theme.geometry.settingsListItem.content.verticalMargin * 2,
				   Theme.geometry.settingsListItem.height)
		: 0
	visible: defaultVisible
	enabled: userHasWriteAccess

	Rectangle {
		id: backgroundRect

		width: root.width
		height: root.height - root.spacing
		radius: Theme.geometry.settingsListItem.radius
		color: root.down ? Theme.color.settingsListItem.down.background : Theme.color.settingsListItem.background
	}

	Label {
		id: primaryLabel

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.settingsListItem.content.horizontalMargin
			right: content.left
			rightMargin: Theme.geometry.settingsListItem.content.spacing
			top: parent.top
			topMargin: Theme.geometry.settingsListItem.content.verticalMargin - root.spacing/2
		}
		font.pixelSize: Theme.font.size.body2
		wrapMode: Text.Wrap
	}

	Row {
		id: content

		anchors {
			right: parent.right
			rightMargin: Theme.geometry.settingsListItem.content.horizontalMargin
			verticalCenter: primaryLabel.verticalCenter
		}
		spacing: Theme.geometry.settingsListItem.content.spacing
	}
}
