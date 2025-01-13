/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
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
	property int leftPadding: flat ? Theme.geometry_listItem_flat_content_horizontalMargin : Theme.geometry_listItem_content_horizontalMargin
	property int rightPadding: flat ? Theme.geometry_listItem_flat_content_horizontalMargin : Theme.geometry_listItem_content_horizontalMargin

	property int showAccessLevel: VenusOS.User_AccessType_User
	property int writeAccessLevel: VenusOS.User_AccessType_Installer
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)
	readonly property bool userHasReadAccess: Global.systemSettings.canAccess(showAccessLevel)

	readonly property alias primaryLabel: primaryLabel

	readonly property int defaultImplicitHeight: contentLayout.height + Theme.geometry_gradientList_spacing
	readonly property int availableWidth: width - leftPadding - rightPadding - content.spacing
	property int maximumContentWidth: availableWidth * 0.7
	property bool allowed: true

	property int bottomContentSizeMode: content.height > primaryLabel.height
				? VenusOS.ListItem_BottomContentSizeMode_Compact
				: VenusOS.ListItem_BottomContentSizeMode_Stretch

	visible: allowed && userHasReadAccess
	implicitHeight: allowed && userHasReadAccess ? defaultImplicitHeight : 0
	implicitWidth: parent ? parent.width : 0

	ListItemBackground {
		id: backgroundRect

		z: -2
		height: root.height - Theme.geometry_gradientList_spacing
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

	GridLayout {
		id: contentLayout

		width: parent.width
		columns: 2
		columnSpacing: Theme.geometry_listItem_content_spacing
		rowSpacing: 0

		Label {
			id: primaryLabel

			Layout.topMargin: Theme.geometry_listItem_content_verticalMargin
			Layout.leftMargin: root.leftPadding
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
			font.pixelSize: flat ? Theme.font_size_body1 : Theme.font_size_body2
			wrapMode: Text.Wrap
			width: root.availableWidth - content.width - Theme.geometry_listItem_content_spacing
		}

		Row {
			id: content

			// The topMargin ensures the content is vertically aligned with primaryLabel when the
			// content height is small and there is no bottom content.
			Layout.topMargin: height <= primaryLabel.height ? Theme.geometry_listItem_content_verticalMargin : 0
			Layout.rightMargin: root.rightPadding
			Layout.maximumWidth: root.maximumContentWidth
			Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
			Layout.rowSpan: root.bottomContentSizeMode === VenusOS.ListItem_BottomContentSizeMode_Stretch ? 1 : 2
			spacing: Theme.geometry_listItem_content_spacing
		}

		Column {
			id: bottomContent

			Layout.fillWidth: true
			Layout.columnSpan: root.bottomContentSizeMode === VenusOS.ListItem_BottomContentSizeMode_Stretch ? 2 : 1
			Layout.topMargin: height > 0 ? Theme.geometry_listItem_content_verticalMargin / 2 : 0
			Layout.bottomMargin: Theme.geometry_listItem_content_verticalMargin
		}
	}
}
