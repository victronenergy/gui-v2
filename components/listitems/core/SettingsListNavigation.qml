/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListNavigation {
	id: root

	property string pageSource: ""
	property string iconSource: ""
	property alias text: primary.text
	property alias secondaryText: secondary.text

	height: Theme.geometry_settingsListNavigation_height
	onClicked: Global.pageManager.pushPage(root.pageSource, {"title": root.text })

	CP.ColorImage {
		id: icon

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_listItem_content_horizontalMargin
			verticalCenter: parent.verticalCenter
		}
		color: Theme.color_font_primary
		source: root.iconSource
	}

	Column {
		anchors {
			left: iconSource ? icon.right : parent.left
			leftMargin: Theme.geometry_listItem_content_horizontalMargin
			verticalCenter: parent.verticalCenter
		}

		Label {
			id: primary

			font.pixelSize: Theme.font_size_body2
			wrapMode: Text.Wrap
			text: root.primaryText
		}

		Label {
			id: secondary

			font.pixelSize: Theme.font_size_body1
			wrapMode: Text.Wrap
			color: Theme.color_font_secondary
			text: root.secondaryText
		}
	}
}
