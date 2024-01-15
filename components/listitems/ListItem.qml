/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property alias text: primaryLabel.text
	property alias content: content
	property alias bottomContent: bottomContent
	property list<Item> bottomContentChildren
	property bool down
	property alias backgroundRect: backgroundRect
	property int spacing: Theme.geometry_gradientList_spacing
	property int bottomContentMargin: Theme.geometry_listItem_content_spacing

	property int showAccessLevel: VenusOS.User_AccessType_User
	property int writeAccessLevel: VenusOS.User_AccessType_Installer
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)
	readonly property bool userHasReadAccess: Global.systemSettings.canAccess(showAccessLevel)

	readonly property bool defaultVisible: userHasReadAccess
	readonly property alias primaryLabel: primaryLabel
	readonly property int defaultImplicitHeight: visible
		? Math.max(Math.max(primaryLabel.implicitHeight + Theme.geometry_listItem_content_verticalMargin*2, content.height)
					+ (bottomContent.height > 0
							? bottomContent.height + bottomContentMargin
							: 0),
				   Theme.geometry_listItem_height)
		: 0

	readonly property int availableWidth: width - primaryLabel.anchors.leftMargin - content.anchors.rightMargin - content.spacing
	property int maximumContentWidth: availableWidth * 0.7

	implicitWidth: parent ? parent.width : 0
	implicitHeight: visible ? defaultImplicitHeight : 0
	visible: defaultVisible

	ListItemBackground {
		id: backgroundRect

		height: root.height - root.spacing
		color: root.down ? Theme.color_listItem_down_background : Theme.color_listItem_background
		// TODO how to indicate read-only setting?

		// Show thin colored indicator on left side if settings is only visible to super/service users
		Rectangle {
			visible: root.showAccessLevel >= VenusOS.User_AccessType_SuperUser
			width: Theme.geometry_listItem_radius * 2
			height: parent.height
			color: Theme.color_listItem_highAccessLevel
			radius: Theme.geometry_listItem_radius

			Rectangle {
				x: Theme.geometry_listItem_radius
				width: Theme.geometry_listItem_radius
				height: parent.height
				color: backgroundRect.color
			}
		}
	}

	Label {
		id: primaryLabel

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_listItem_content_horizontalMargin
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: -root.spacing/2
				- (bottomContent.height > 0
						? bottomContent.height/2 + bottomContentMargin/2
						: 0)
		}
		font.pixelSize: Theme.font_size_body2
		wrapMode: Text.Wrap
		width: root.availableWidth - content.width
	}

	Row {
		id: content

		anchors {
			right: parent.right
			rightMargin: Theme.geometry_listItem_content_horizontalMargin
			verticalCenter: primaryLabel.verticalCenter
		}
		spacing: Theme.geometry_listItem_content_spacing
		width: Math.min(implicitWidth, root.maximumContentWidth)
	}

	Column {
		id: bottomContent
		y: Math.max(primaryLabel.y + primaryLabel.height + bottomContentMargin,
			content.y + content.height + bottomContentMargin)
		width: parent.width
		children: root.bottomContentChildren
	}
}
