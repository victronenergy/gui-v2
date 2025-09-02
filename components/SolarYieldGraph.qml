/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Row {
	id: root

	property int maximumBarCount

	readonly property real availableWidth: width - leftPadding - rightPadding
	readonly property real _barWidth: (availableWidth - ((yieldModel.count - 1) * spacing)) / yieldModel.count

	Repeater {
		id: dayRepeater

		model: SolarYieldModel {
			id: yieldModel
			firstDay: 0
			lastDay: root.maximumBarCount - 1
		}

		delegate: Rectangle {
			anchors.bottom: parent.bottom
			height: yieldModel.maximumYield > 0
					? root.height * (model.yieldKwh / yieldModel.maximumYield)
					: 0
			width: root._barWidth
			radius: Theme.geometry_overviewPage_widget_solar_graph_bar_radius
			color: Theme.color_overviewPage_widget_solar_graph_bar
		}
	}
}
