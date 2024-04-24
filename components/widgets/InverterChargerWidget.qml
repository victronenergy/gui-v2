/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	onClicked: {
		if (Global.inverterChargers.veBusDevices.count
				+ Global.inverterChargers.multiDevices.count
				+ Global.inverterChargers.inverterDevices.count > 1) {
			Global.pageManager.pushPage("/pages/invertercharger/InverterChargerListPage.qml")
		} else {
			const device = Global.inverterChargers.first
			if (device.serviceUid.indexOf('inverter') >= 0) {
				Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterPage.qml",
						{ "serviceUid": device.serviceUid, "title": device.name })
			} else {
				Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterChargerPage.qml",
						{ "inverterCharger": device })
			}
		}
	}

	//% "Inverter / Charger"
	title: qsTrId("overview_widget_inverter_title")
	icon.source: "qrc:/images/inverter_charger.svg"
	type: VenusOS.OverviewWidget_Type_VeBusDevice
	enabled: !!Global.inverterChargers.first
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
		}
	}
}
