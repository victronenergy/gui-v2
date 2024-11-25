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
	property alias bottomContentChildren: bottomContent.children
	property bool down
	property bool flat
	property alias backgroundRect: backgroundRect
	property int spacing: Theme.geometry_gradientList_spacing
	property int bottomContentMargin: Theme.geometry_listItem_content_spacing
	property int leftPadding: flat ? Theme.geometry_listItem_flat_content_horizontalMargin : Theme.geometry_listItem_content_horizontalMargin
	property int rightPadding: flat ? Theme.geometry_listItem_flat_content_horizontalMargin : Theme.geometry_listItem_content_horizontalMargin

	property int showAccessLevel: VenusOS.User_AccessType_User
	property int writeAccessLevel: VenusOS.User_AccessType_Installer
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)
	readonly property bool userHasReadAccess: Global.systemSettings.canAccess(showAccessLevel)

	readonly property bool defaultAllowed: userHasReadAccess
	readonly property alias primaryLabel: primaryLabel
	readonly property int defaultImplicitHeight: {
		const bottomHeight = bottomContent.height > 0 ? bottomContent.height + bottomContentMargin : 0
		const labelHeight = primaryLabel.implicitHeight + Theme.geometry_listItem_content_verticalMargin*2
		return Math.max(flat ? Theme.geometry_listItem_flat_height : Theme.geometry_listItem_height,
						Math.max(content.height, labelHeight) + bottomHeight)
	}

	readonly property int availableWidth: width - leftPadding - rightPadding - content.spacing
	property int maximumContentWidth: availableWidth * 0.7
	property bool allowed: defaultAllowed

	visible: allowed
	implicitHeight: allowed ? defaultImplicitHeight : 0
	implicitWidth: parent ? parent.width : 0

	ListItemBackground {
		id: backgroundRect

		z: -2
		height: root.height - root.spacing
		color: Theme.color_listItem_background
		visible: !root.flat
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
			leftMargin: root.leftPadding
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: -root.spacing/2
				- (bottomContent.height > 0
						? bottomContent.height/2 + bottomContentMargin/2
						: 0)
		}
		font.pixelSize: flat ? Theme.font_size_body1 : Theme.font_size_body2
		wrapMode: Text.Wrap
		width: root.availableWidth - content.width - Theme.geometry_listItem_content_spacing
	}

	Row {
		id: content

		anchors {
			right: parent.right
			rightMargin: root.rightPadding
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
	}
}
