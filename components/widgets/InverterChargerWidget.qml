/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

OverviewWidget {
	id: root

	onClicked: {
		if (Global.inverterChargers.deviceCount > 1) {
			Global.pageManager.pushPage("/pages/invertercharger/InverterChargerListPage.qml")
		} else {
			// Show page for chargers
			chargerModelLoader.active = true
			if (chargerModelLoader.item.count > 0) {
				const charger = chargerModelLoader.item.firstObject
				Global.pageManager.pushPage("/pages/settings/devicelist/PageAcCharger.qml",
						{ "bindPrefix": charger.serviceUid })
			} else {
				// Show page for inverter, vebus and acsystem services
				const device = Global.inverterChargers.firstObject
				Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterChargerPage.qml",
						{ "serviceUid": device.serviceUid })
			}
		}
	}

	type: VenusOS.OverviewWidget_Type_VeBusDevice
	enabled: !!Global.inverterChargers.firstObject
	rightPadding: Theme.geometry_overviewPage_widget_content_horizontalMargin
			+ Theme.geometry_overviewPage_widget_sideGauge_margins

	contentItem: ColumnLayout {
		spacing: 0

		WidgetHeader {
			//% "Inverter / Charger"
			text: qsTrId("overview_widget_inverter_title")
			icon.source: "qrc:/images/inverter_charger.svg"
			Layout.fillWidth: true
		}

		Label {
			text: Global.system.systemStateToText(Global.system.state)
			font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_maximumSize
			minimumPixelSize: Theme.font_overviewPage_widget_quantityLabel_minimumSize
			fontSizeMode: Text.Fit
			wrapMode: Text.WordWrap
			maximumLineCount: 4
			elide: Text.ElideRight

			Layout.fillWidth: true
			Layout.fillHeight: true // push reason text to bottom of layout
		}

		Label {
			text: systemReason.text
			wrapMode: Text.WordWrap
			color: Theme.color_font_secondary
			font.pixelSize: Theme.font_overviewPage_secondary

			SystemReason {
				id: systemReason
			}
		}
	}

	Loader {
		id: sideGaugeLoader

		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry_overviewPage_widget_sideGauge_margins
		}
		sourceComponent: ThreePhaseBarGauge {
			valueType: VenusOS.Gauges_ValueType_RisingPercentage
			phaseModel: Global.system.load.ac.phases
			maximumValue: Global.system.load.maximumAcCurrent
			animationEnabled: root.animationEnabled
			inOverviewWidget: true
		}
	}

	Loader {
		id: chargerModelLoader
		active: false
		sourceComponent: FilteredDeviceModel {
			serviceTypes: ["charger"]
			sorting: FilteredDeviceModel.DeviceInstance
		}
	}
}
