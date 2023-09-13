/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Utils

Item {
	id: root

	readonly property int _maxBars: Math.max(0, width / (Theme.geometry.overviewPage.widget.solar.graph.bar.width
		+ Theme.geometry.overviewPage.widget.solar.graph.margins))

	Row {
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
		}
		width: (_maxBars * Theme.geometry.overviewPage.widget.solar.graph.bar.width)
			+ ((_maxBars-1) * Theme.geometry.overviewPage.widget.solar.graph.margins)
		spacing: Theme.geometry.overviewPage.widget.solar.graph.margins

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
				width: Theme.geometry.overviewPage.widget.solar.graph.bar.width
				radius: Theme.geometry.overviewPage.widget.solar.graph.bar.radius
				color: Theme.color.overviewPage.widget.solar.graph.bar
			}
		}
	}
}
