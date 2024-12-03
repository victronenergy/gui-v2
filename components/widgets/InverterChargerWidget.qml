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
				+ Global.inverterChargers.acSystemDevices.count) > 1) {
			Global.pageManager.pushPage("/pages/invertercharger/InverterChargerListPage.qml")
		} else {
			// Show page for chargers
			if (Global.chargers.model.count) {
				const charger = Global.chargers.model.firstObject
				Global.pageManager.pushPage("/pages/settings/devicelist/PageAcCharger.qml",
						{ "bindPrefix": charger.serviceUid, "title": charger.name })
			} else {
				// Show page for inverter, vebus and acsystem services
				const device = Global.inverterChargers.firstObject
				Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterChargerPage.qml",
						{ "serviceUid": device.serviceUid, "title": device.name })
			}
		}
	}

	//% "Inverter / Charger"
	title: qsTrId("overview_widget_inverter_title")
	icon.source: "qrc:/images/inverter_charger.svg"
	type: VenusOS.OverviewWidget_Type_VeBusDevice
	enabled: !!Global.inverterChargers.firstObject || Global.chargers.model.count
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
				bottom: systemReasonText.top
			}
			text: Global.system.systemStateToText(Global.system.state)
			font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_maximumSize
			minimumPixelSize: Theme.font_overviewPage_widget_quantityLabel_minimumSize
			fontSizeMode: Text.VerticalFit
			wrapMode: Text.Wrap
			maximumLineCount: 4
			elide: Text.ElideRight
		},
		Label {
			id: systemReasonText

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_content_verticalMargin
			}
			text: systemReason.text
			wrapMode: Text.WordWrap
			color: Theme.color_font_secondary
			SystemReason {
				id: systemReason
			}
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
			phaseModel: Global.system.load.ac.phases
			phaseModelProperty: "current"
			maximumValue: Global.system.load.maximumAcCurrent
			animationEnabled: root.animationEnabled
			inOverviewWidget: true
		}
	}
}
