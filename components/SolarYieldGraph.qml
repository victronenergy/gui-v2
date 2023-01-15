/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

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

			property real maximumYieldValue
			property int maximumYieldIndex: -1

			model: Global.solarChargers.yieldHistory.slice(0, root._maxBars)

			delegate: Rectangle {
				readonly property real yieldValue: modelData

				anchors.bottom: parent.bottom
				height: Math.max(1, root.height * (yieldValue / Math.max(1, dayRepeater.maximumYieldValue)))
				width: Theme.geometry.overviewPage.widget.solar.graph.bar.width
				radius: Theme.geometry.overviewPage.widget.solar.graph.bar.radius
				color: Theme.color.overviewPage.widget.solar.graph.bar

				onYieldValueChanged: Utils.updateMaximumYield(dayRepeater, model.index, yieldValue)
			}
		}
	}
}
