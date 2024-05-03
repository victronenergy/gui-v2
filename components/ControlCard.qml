/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import QtQuick.Controls as C
import Victron.VenusOS

FocusScope {
	property alias icon: icon
	property alias title: title
	property alias status: status

	width: Theme.geometry_controlCard_maximumWidth
	height: parent ? parent.height : 0
	property alias color: background.color

	Rectangle {
		id: background
		anchors.fill: parent
		color: Theme.color_background_secondary
		radius: Theme.geometry_panel_radius
	}

	CP.ColorImage {
		id: icon

		anchors {
			top: parent.top
			topMargin: Theme.geometry_controlCard_title_topMargin
			left: parent.left
			leftMargin: Theme.geometry_controlCard_contentMargins
		}
		color: Theme.color_font_primary
	}

	Label {
		id: title

		anchors {
			top: parent.top
			topMargin: Theme.geometry_controlCard_title_topMargin
			left: icon.right
			leftMargin: Theme.geometry_controlCard_title_spacing
			right: parent.right
			rightMargin: Theme.geometry_controlCard_title_spacing
		}
		font.pixelSize: Theme.font_size_body1
		color: Theme.color_font_primary
		elide: Text.ElideRight
	}

	Label {
		id: status

		anchors {
			top: title.bottom
			topMargin: Theme.geometry_controlCard_status_topMargin
			left: parent.left
			leftMargin: Theme.geometry_controlCard_contentMargins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_contentMargins
		}
		font.pixelSize: Theme.font_size_body3
		wrapMode: Text.Wrap
	}
}
