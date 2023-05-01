/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property real _yieldToday: NaN

	//% "Solar yield"
	title: qsTrId("overview_widget_solaryield_title")
	icon.source: "qrc:/images/solaryield.svg"
	type: VenusOS.OverviewWidget_Type_Solar

	quantityLabel.dataObject: Global.solarChargers

	extraContent.children: [
		Label {
			id: yieldLabel
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
			text: qsTrId("overview_widget_solaryield_today").arg(isNaN(root._yieldToday) ? "--" : root._yieldToday)
			color: Theme.color.font.secondary
			visible: root.size >= VenusOS.OverviewWidget_Size_M
		},
		SolarYieldGraph {
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: Theme.geometry.overviewPage.widget.solar.graph.margins
			}
			visible: root.size >= VenusOS.OverviewWidget_Size_L
			width: parent.width - Theme.geometry.overviewPage.widget.solar.graph.margins*2
			height: Math.min(parent.height / 2,
				parent.height - yieldLabel.y - yieldLabel.height - 2*Theme.geometry.overviewPage.widget.solar.graph.margins)
		}
	]

	MouseArea {
		anchors.fill: parent
		enabled: Global.solarChargers.model.count > 0
		onClicked: {
			if (Global.solarChargers.model.count === 1) {
				Global.pageManager.pushLayer("/pages/solaryield/SolarChargerPage.qml",
						{ "solarCharger": Global.solarChargers.model.get(0).solarCharger })
			} else {
				Global.pageManager.pushLayer("/pages/solaryield/SolarChargerListPage.qml", { "title": root.title })
			}
		}
	}

	Instantiator {
		model: SolarYieldModel {
			dayRange: [0, 1]
		}
		delegate: QtObject {
			readonly property real yieldKwh: model.yieldKwh
			onYieldKwhChanged: root._yieldToday = yieldKwh
		}
	}
}
