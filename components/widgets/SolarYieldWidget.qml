/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "Solar yield"
	title: qsTrId("overview_widget_solaryield_title")
	icon.source: "qrc:/images/solaryield.svg"
	type: VenusOS.OverviewWidget_Type_Solar

	quantityLabel.dataObject: Global.solarChargers

	extraContent.children: [
		Label {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				top: parent.top
				topMargin: Theme.geometry.overviewPage.widget.extraContent.topMargin
			}
			//: Today's solar yield, in kwh
			//% "Today: %1kwh"
			text: qsTrId("overview_widget_solaryield_today").arg(Math.floor(Global.solarChargers.yieldHistory[0] || 0))
			color: Theme.color.font.secondary
			visible: root.size >= VenusOS.OverviewWidget_Size_M
		},
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
		}
	]
}
