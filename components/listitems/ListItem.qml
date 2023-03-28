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
	property int spacing: Theme.geometry.gradientList.spacing

	property int showAccessLevel: VenusOS.User_AccessType_User
	property int writeAccessLevel: VenusOS.User_AccessType_Installer
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)
	readonly property bool userHasReadAccess: Global.systemSettings.canAccess(showAccessLevel)

	readonly property bool defaultVisible: userHasReadAccess
	readonly property alias primaryLabel: primaryLabel
	readonly property int defaultImplicitHeight: visible
		? Math.max(primaryLabel.implicitHeight + Theme.geometry.listItem.content.verticalMargin * 2,
				   content.height,
				   Theme.geometry.listItem.height)
		: 0

	readonly property int availableWidth: width - primaryLabel.anchors.leftMargin - content.anchors.rightMargin - content.spacing
	property int maximumContentWidth: availableWidth * 0.7

	implicitWidth: parent ? parent.width : 0
	implicitHeight: defaultImplicitHeight
	visible: defaultVisible

	ListItemBackground {
		id: backgroundRect

		height: root.height - root.spacing
		color: root.down ? Theme.color.listItem.down.background : Theme.color.listItem.background
		// TODO how to indicate read-only setting?

		// Show thin colored indicator on left side if settings is only visible to super/service users
		Rectangle {
			visible: root.showAccessLevel >= VenusOS.User_AccessType_SuperUser
			width: Theme.geometry.listItem.radius * 2
			height: parent.height
			color: Theme.color.listItem.highAccessLevel
			radius: Theme.geometry.listItem.radius

			Rectangle {
				x: Theme.geometry.listItem.radius
				width: Theme.geometry.listItem.radius
				height: parent.height
				color: backgroundRect.color
			}
		}
	}

	Label {
		id: primaryLabel

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.listItem.content.horizontalMargin
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: -root.spacing/2
		}
		font.pixelSize: Theme.font.size.body2
		wrapMode: Text.Wrap
		width: Math.min(implicitWidth, root.availableWidth, root.availableWidth - content.width)
	}

	Row {
		id: content

		anchors {
			right: parent.right
			rightMargin: Theme.geometry.listItem.content.horizontalMargin
			verticalCenter: primaryLabel.verticalCenter
		}
		spacing: Theme.geometry.listItem.content.spacing
		width: Math.min(implicitWidth, root.maximumContentWidth)
	}
}
