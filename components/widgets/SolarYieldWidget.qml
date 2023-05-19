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
		SolarYieldGraph {
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: Theme.geometry.overviewPage.widget.solar.graph.margins
			}
			visible: root.size >= VenusOS.OverviewWidget_Size_L
			width: parent.width - Theme.geometry.overviewPage.widget.solar.graph.margins*2
			height: parent.height - (2 * Theme.geometry.overviewPage.widget.solar.graph.margins)
		}
	]

	MouseArea {
		anchors.fill: parent
		enabled: Global.solarChargers.model.count > 0
		onClicked: {
			if (Global.solarChargers.model.count === 1) {
				Global.pageManager.pushLayer("/pages/solar/SolarChargerPage.qml",
						{ "solarCharger": Global.solarChargers.model.get(0).solarCharger })
			} else {
				Global.pageManager.pushLayer("/pages/solar/SolarChargerListPage.qml", { "title": root.title })
			}
		}
	}
}
