/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property var history: []

	property var _displayedHistory: {
		if (!history) {
			return []
		}
		let maxBars = Math.max(0, width / (Theme.geometry.overviewPage.widget.solar.graph.bar.width
			+ Theme.geometry.overviewPage.widget.solar.graph.margins))
		return history.slice(0, maxBars)
	}

	property var _maxValue: {
		var currMax = 0
		for (var i = 0; i < _displayedHistory.length; ++i) {
			if (currMax < _displayedHistory[i]) {
				currMax = _displayedHistory[i]
			}
		}
		return currMax
	}

	Row {
		anchors.horizontalCenter: parent.horizontalCenter
		width: (_displayedHistory.length * Theme.geometry.overviewPage.widget.solar.graph.bar.width)
			+ ((_displayedHistory.length-1) * Theme.geometry.overviewPage.widget.solar.graph.margins)
		spacing: Theme.geometry.overviewPage.widget.solar.graph.margins

		Repeater {
			model: root._displayedHistory

			Rectangle {
				anchors.bottom: parent.bottom
				height: root.height * (modelData / root._maxValue)
				width: Theme.geometry.overviewPage.widget.solar.graph.bar.width
				radius: Theme.geometry.overviewPage.widget.solar.graph.bar.radius
				color: Theme.color.overviewPage.widget.solar.graph.bar
			}
		}
	}
}
