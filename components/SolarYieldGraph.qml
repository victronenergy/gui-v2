/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	readonly property int _maxBars: Math.max(0, width / (Theme.geometry_overviewPage_widget_solar_graph_bar_width
		+ Theme.geometry_overviewPage_widget_solar_graph_margins))

	Row {
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
		}
		width: (_maxBars * Theme.geometry_overviewPage_widget_solar_graph_bar_width)
			+ ((_maxBars-1) * Theme.geometry_overviewPage_widget_solar_graph_margins)
		spacing: Theme.geometry_overviewPage_widget_solar_graph_margins

		Repeater {
			id: dayRepeater

			model: SolarYieldModel {
				id: yieldModel
				dayRange: [0, root._maxBars]
			}

			delegate: Rectangle {
				anchors.bottom: parent.bottom
				height: yieldModel.maximumYield > 0
						? root.height * (model.yieldKwh / yieldModel.maximumYield)
						: 0
				width: Theme.geometry_overviewPage_widget_solar_graph_bar_width
				radius: Theme.geometry_overviewPage_widget_solar_graph_bar_radius
				color: Theme.color_overviewPage_widget_solar_graph_bar
			}
		}
	}
}
