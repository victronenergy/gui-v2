/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property var history: []
	property var maxValue: {
		var currMax = 0
		for (var i = 0; i < history.length; ++i) {
			if (currMax < history[i]) {
				currMax = history[i]
			}
		}
		return currMax
	}

	implicitWidth: row.implicitWidth

	Row {
		id: row
		spacing: Theme.geometry.overviewPage.widget.solar.graph.margins
		Repeater {
			model: root.history
			Rectangle {
				anchors.bottom: parent.bottom
				height: root.height * (modelData / root.maxValue)
				width: Theme.geometry.overviewPage.widget.solar.graph.bar.width
				radius: Theme.geometry.overviewPage.widget.solar.graph.bar.radius
				color: Theme.color.overviewPage.widget.solar.graph.bar
			}
		}
	}
}
