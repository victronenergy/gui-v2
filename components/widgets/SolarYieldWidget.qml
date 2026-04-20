/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

OverviewWidget {
	id: root

	readonly property bool _showPhases: Global.solarInputs.pvInverterDevices.count === 1
			&& Global.solarInputs.devices.count === 0
	readonly property bool _showGraph: Global.solarInputs.pvInverterDevices.count === 0

	onClicked: {
		const singleDeviceOnly = (Global.solarInputs.devices.count + Global.solarInputs.pvInverterDevices.count) === 1
		if (singleDeviceOnly && Global.solarInputs.devices.count === 1) {
			Global.pageManager.pushPage("/pages/solar/SolarDevicePage.qml",
					{ "serviceUid": Global.solarInputs.devices.firstObject.serviceUid })
		} else if (singleDeviceOnly && Global.solarInputs.pvInverterDevices.count === 1) {
			Global.pageManager.pushPage("/pages/solar/PvInverterPage.qml",
					{ "serviceUid": Global.solarInputs.pvInverterDevices.firstObject.serviceUid })
		} else {
			Global.pageManager.pushPage("/pages/solar/SolarInputListPage.qml", { "title": root.title })
		}
	}

	//% "Solar yield"
	title: qsTrId("overview_widget_solaryield_title")
	type: VenusOS.OverviewWidget_Type_Solar
	enabled: true
	preferredSize: _showPhases || _showGraph
			? VenusOS.OverviewWidget_PreferredSize_PreferLarge
			: VenusOS.OverviewWidget_PreferredSize_Any
	bottomPadding: _showGraph
			? Theme.geometry_overviewPage_widget_content_bottomMargin_large
			: Theme.geometry_overviewPage_widget_content_bottomMargin_small

	// Solar yield history is only available for PV chargers, and phase data is only available for
	// PV inverters. So, if there are only solar chargers, show the solar history; otherwise if
	// there is a single PV inverter, show its phase data.
	contentItem: ColumnLayout {
		WidgetHeader {
			text: root.title
			icon.source: "qrc:/images/solaryield.svg"
			Layout.fillWidth: true
		}

		OverviewElectricalQuantityLabel {
			widgetSize: root.size
			dataObject: Global.system.solar
			Layout.fillWidth: true
			Layout.fillHeight: !root._showGraph // when graph is shown, allow it to expand to full height
		}

		Loader {
			id: contentLoader

			sourceComponent: {
				if (root.size >= VenusOS.OverviewWidget_Size_L) {
					if (root._showPhases) {
						return phaseComponent
					} else if (root._showGraph) {
						return historyComponent
					}
				}
				// If there are both chargers and inverters, do not show the history (as inverters
				// do not have history) and also do not show phase data (as we cannot combine the
				// phase data from inverters and chargers together).
				return null
			}

			Layout.fillWidth: true
			Layout.fillHeight: root._showGraph // do not stretch 3-phase display as it needs to anchor to widget bottom
			Layout.alignment: Qt.AlignBottom
		}
	}

	Component {
		id: phaseComponent

		ThreePhaseDisplay {
			model: pvInverter.phases
			visible: model.count > 1
			widgetSize: root.size

			PvInverter {
				id: pvInverter
				serviceUid: Global.solarInputs.pvInverterDevices.firstObject?.serviceUid ?? ""
			}
		}
	}

	Component {
		id: historyComponent

		SolarYieldGraph {
			maximumBarCount: Theme.geometry_overviewPage_widget_solar_graph_bar_count
		}
	}
}
