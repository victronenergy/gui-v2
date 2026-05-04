/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// This is an item rather than a Row, because a bar in the graph may have 0 height, and in that
// case it is omitted from a Row altogether.
Item {
	id: root

	readonly property int maximumBarCount: (width + Theme.geometry_overviewPage_widget_solar_graph_bar_spacing)
		/ (Theme.geometry_overviewPage_widget_solar_graph_bar_width + Theme.geometry_overviewPage_widget_solar_graph_bar_spacing)

	Repeater {
		model: SolarYieldModel {
			id: yieldModel
			firstDay: 0
			lastDay: root.maximumBarCount - 1
		}

		delegate: Rectangle {
			x: model.index * Theme.geometry_overviewPage_widget_solar_graph_bar_width
				+ (Theme.geometry_overviewPage_widget_solar_graph_bar_spacing * model.index)
			y: parent.height - height
			height: yieldModel.maximumYield > 0
					? root.height * (model.yieldKwh / yieldModel.maximumYield)
					: 0
			width: Theme.geometry_overviewPage_widget_solar_graph_bar_width
			radius: Theme.geometry_overviewPage_widget_solar_graph_bar_radius
			color: Theme.color_overviewPage_widget_solar_graph_bar
		}
	}
}
