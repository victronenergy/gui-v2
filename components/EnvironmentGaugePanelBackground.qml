/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	required property string title

	implicitWidth: Theme.geometry_levelsPage_panel_background_width
	implicitHeight: Theme.geometry_levelsPage_panel_background_height

	// The colour indicator is on the top in landscape, and not visible in portrait.
	Rectangle {
		id: colorIndicator

		width: parent.width
		height: Theme.geometry_levelsPage_panel_header_height
		topLeftRadius: Theme.geometry_levelsPage_panel_radius
		topRightRadius: Theme.geometry_levelsPage_panel_radius
		color: Theme.color_environmentGaugePanel_header
		visible: Theme.screenSize !== Theme.Portrait

		Label {
			anchors {
				left: parent.left
				right: parent.right
				bottom: parent.bottom
				margins: Theme.geometry_levelsPage_panel_background_title_padding
			}
			horizontalAlignment: Text.AlignHCenter
			elide: Text.ElideRight
			text: root.title
		}
	}

	// Fill out the rest of the background with a background colour.
	Rectangle {
		anchors {
			fill: parent
			topMargin: Theme.geometry_levelsPage_panel_header_height
		}
		border.color: Theme.screenSize === Theme.Portrait ? "transparent" : Theme.color_environmentGaugePanel_header
		color: Theme.color_environmentGaugePanel_background
		topLeftRadius: colorIndicator.visible ? 0 : Theme.geometry_levelsPage_panel_radius
		topRightRadius: colorIndicator.visible ? 0 : Theme.geometry_levelsPage_panel_radius
		bottomLeftRadius: Theme.geometry_levelsPage_panel_radius
		bottomRightRadius: Theme.geometry_levelsPage_panel_radius
	}
}
