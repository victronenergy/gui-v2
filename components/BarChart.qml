/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListView {
	id: listView

	height: Theme.geometry.barChart.height
	orientation: ListView.Horizontal
	spacing: Theme.geometry.barChart.spacing
	delegate: Rectangle {
		anchors.bottom: parent.bottom
		width: Theme.geometry.barChart.barWidth
		radius: Theme.geometry.barChart.barRadius
		color: Theme.color.ok
		height: modelData * parent.height
	}
}
