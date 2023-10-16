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
	enabled: true
	quantityLabel.dataObject: Global.system.solar

	// Solar yield history is only available for PV chargers, and phase data is only available for
	// PV inverters. So, if there are only solar chargers, show the solar history; otherwise if
	// there is a single PV inverter, show its phase data.
	extraContent.children: [
		Loader {
			readonly property int margin: sourceComponent === historyComponent
				  ? Theme.geometry.overviewPage.widget.solar.graph.margins
				  : Theme.geometry.overviewPage.widget.extraContent.bottomMargin

			anchors {
				left: parent.left
				leftMargin: margin
				right: parent.right
				rightMargin: margin
				bottom: parent.bottom
				bottomMargin: margin
			}
			sourceComponent: {
				if (root.size >= VenusOS.OverviewWidget_Size_L) {
					if (Global.pvInverters.model.count === 1 && Global.solarChargers.model.count === 0) {
						return phaseComponent
					} else if (Global.pvInverters.model.count === 0) {
						return historyComponent
					}
				}
				return null
			}
		}
	]

	Component {
		id: phaseComponent

		ThreePhaseDisplay {
			model: Global.pvInverters.model.deviceAt(0).phases
			visible: model.count > 1
		}
	}

	Component {
		id: historyComponent

		SolarYieldGraph {
			height: root.extraContent.height - (2 * Theme.geometry.overviewPage.widget.solar.graph.margins)
		}
	}

	MouseArea {
		anchors.fill: parent
		onClicked: {
			const singleDeviceOnly = (Global.solarChargers.model.count + Global.pvInverters.model.count) === 1
			if (singleDeviceOnly && Global.solarChargers.model.count === 1) {
				Global.pageManager.pushPage("/pages/solar/SolarChargerPage.qml",
						{ "solarCharger": Global.solarChargers.model.deviceAt(0) })
			} else if (singleDeviceOnly && Global.pvInverters.model === 1) {
				Global.pageManager.pushPage("/pages/solar/PvInverterPage.qml",
						{ "pvInverter": Global.pvInverters.model.deviceAt(0) })
			} else {
				Global.pageManager.pushPage("/pages/solar/SolarDeviceListPage.qml", { "title": root.title })
			}
		}
	}
}
