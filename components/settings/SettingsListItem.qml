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
	property int writeAccessLevel: VenusOS.User_AccessType_Installer
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)

	readonly property bool defaultVisible: Global.systemSettings.canAccess(showAccessLevel)
	readonly property alias primaryLabel: primaryLabel
	readonly property int defaultImplicitHeight: visible
		? Math.max(primaryLabel.implicitHeight + Theme.geometry.settingsListItem.content.verticalMargin * 2,
				   Theme.geometry.settingsListItem.height)
		: 0

	readonly property int availableWidth: width - primaryLabel.anchors.leftMargin - content.anchors.rightMargin - content.spacing

	implicitWidth: parent ? parent.width : 0
	implicitHeight: defaultImplicitHeight
	visible: defaultVisible
	enabled: userHasWriteAccess

	Rectangle {
		id: backgroundRect

		width: root.width
		height: root.height - root.spacing
		radius: Theme.geometry.settingsListItem.radius
		color: root.down ? Theme.color.settingsListItem.down.background : Theme.color.settingsListItem.background
		// TODO how to indicate read-only setting?

		// Show thin colored indicator on left side if settings is only visible to super/service users
		Rectangle {
			visible: root.showAccessLevel >= VenusOS.User_AccessType_SuperUser
			width: Theme.geometry.settingsListItem.radius * 2
			height: parent.height
			color: Theme.color.settingsListItem.highAccessLevel
			radius: Theme.geometry.settingsListItem.radius

			Rectangle {
				x: Theme.geometry.settingsListItem.radius
				width: Theme.geometry.settingsListItem.radius
				height: parent.height
				color: backgroundRect.color
			}
		}
	}

	Label {
		id: primaryLabel

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.settingsListItem.content.horizontalMargin
			top: parent.top
			topMargin: Theme.geometry.settingsListItem.content.verticalMargin - root.spacing/2
		}
		font.pixelSize: Theme.font.size.body2
		wrapMode: Text.Wrap
		width: Math.min(implicitWidth, root.availableWidth, root.availableWidth - content.width)
	}

	Row {
		id: content

		anchors {
			right: parent.right
			rightMargin: Theme.geometry.settingsListItem.content.horizontalMargin
			verticalCenter: primaryLabel.verticalCenter
		}
		spacing: Theme.geometry.settingsListItem.content.spacing
		width: Math.min(implicitWidth, root.availableWidth)
	}
}
