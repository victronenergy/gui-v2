/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	objectName: "SolarYieldWidget"

	property var yieldHistory: []

	//% "Solar yield"
	title.text: qsTrId("overview_widget_solaryield_title")
	icon.source: "qrc:/images/solaryield.svg"
	type: VenusOS.OverviewWidget_Type_Solar

	extraContent.children: [
		SolarYieldGraph {
			id: barGraph
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: Theme.geometry.overviewPage.widget.solar.graph.margins
			}
			visible: root.size >= VenusOS.OverviewWidget_Size_L
			width: root.width - Theme.geometry.overviewPage.widget.solar.graph.margins*2
			height: Theme.geometry.overviewPage.widget.solar.graph.height
			history: root.yieldHistory
		}
	]
}
