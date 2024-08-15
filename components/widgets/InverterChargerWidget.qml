/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	onClicked: {
		if ((Global.inverterChargers.veBusDevices.count
				+ Global.inverterChargers.inverterDevices.count
				+ Global.chargers.model.count
				+ Global.acSystemDevices.model.count) > 1) {
			Global.pageManager.pushPage("/pages/invertercharger/InverterChargerListPage.qml")
		} else {
			// Show page for chargers
			if (Global.chargers.model.count) {
				const charger = Global.chargers.model.firstObject
				Global.pageManager.pushPage("/pages/settings/devicelist/PageAcCharger.qml",
						{ "bindPrefix": charger.serviceUid, "title": charger.name })
			} else {
				// Show page for inverter, vebus and acsystem services
				const device = Global.inverterChargers.first
				Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterChargerPage.qml",
						{ "serviceUid": device.serviceUid, "title": device.name })
			}
		}
	}

	//% "Inverter / Charger"
	title: qsTrId("overview_widget_inverter_title")
	icon.source: "qrc:/images/inverter_charger.svg"
	type: VenusOS.OverviewWidget_Type_VeBusDevice
	enabled: !!Global.inverterChargers.first || Global.chargers.model.count
	quantityLabel.visible: false
	rightPadding: Theme.geometry_overviewPage_widget_sideGauge_margins
	extraContentChildren: [
		Label {
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: parent.bottom
			}
			text: Global.system.systemStateToText(Global.system.state)
			font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_maximumSize
			minimumPixelSize: Theme.font_overviewPage_widget_quantityLabel_minimumSize
			fontSizeMode: Text.VerticalFit

			wrapMode: Text.Wrap
			maximumLineCount: 4
			elide: Text.ElideRight
		}
	]

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
			phaseModel: Global.system.ac.consumption.phases
			phaseModelProperty: "current"
			maximumValue: Global.system.ac.consumption.maximumCurrent
			animationEnabled: root.animationEnabled
			inOverviewWidget: true
		}
	}
}
