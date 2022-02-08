/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "Solar yield"
	title.text: qsTrId("overview_widget_solaryield_title")
	icon.source: "qrc:/images/solaryield.svg"

	extraContent.children: [
		Label {
			id: statusLabel
			text: "Today: XYZ kW" // TODO: data model
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.leftMargin
			}
		},

		SolarYieldGraph {
			id: barGraph
			anchors {
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.leftMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry.overviewPage.widget.solar.graph.margins
			}
			width: root.width - anchors.leftMargin
			height: Theme.geometry.overviewPage.widget.solar.graph.height
		}
	]
}
