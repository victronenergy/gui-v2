/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Rectangle {
	id: root

	property alias header: header
	property alias icon: img.source
	property real level
	property alias gauge: loader.sourceComponent
	property real totalCapacity
	property real totalRemaining

	color: Theme.color_levelsPage_gauge_backgroundColor
	radius: Theme.geometry_levelsPage_panel_radius
	border.width: Theme.geometry_levelsPage_panel_border_width
	border.color: Theme.color_levelsPage_panel_border_color

	GaugeHeader {
		id: header
		textColor: Theme.color_levelsPage_tank_title
	}

	CP.ColorImage {
		id: img
		anchors {
			top: header.bottom
			topMargin: Theme.geometry_levelsPage_panel_spacing
			horizontalCenter: parent.horizontalCenter
		}
		color: Theme.color_levelsPage_tankIcon
	}

	Loader {
		id: loader
		anchors {
			top: img.bottom
			topMargin: Theme.geometry_levelsPage_panel_spacing
			bottom: percentageText.top
			bottomMargin: Theme.geometry_levelsPage_subgauges_bottomMargin
			horizontalCenter: parent.horizontalCenter
		}
	}

	QuantityLabel {
		id: percentageText

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: valueText.top
			bottomMargin: Theme.geometry_levelsPage_gauge_valueText_topMargin
		}
		font.pixelSize: Theme.font_size_h1
		unit: VenusOS.Units_Percentage
		value: root.level
	}

	Label {
		id: valueText

		anchors {
			bottom: parent.bottom
			bottomMargin: Theme.geometry_levelsPage_panel_spacing
			horizontalCenter: parent.horizontalCenter
		}
		width: parent.width - 2 * Theme.geometry_levelsPage_panel_horizontalMargin
		horizontalAlignment: Text.AlignHCenter
		fontSizeMode: Text.HorizontalFit
		font.pixelSize: Theme.font_size_caption
		color: Theme.color_font_secondary
		opacity: isNaN(root.totalCapacity) && isNaN(root.totalRemaining) ? 0.0 : 1.0
		text: Units.getCapacityDisplayText(Global.systemSettings.volumeUnit, root.totalCapacity, root.totalRemaining)
	}
}
