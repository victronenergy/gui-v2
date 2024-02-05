/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "Inverter / Charger"
	title: qsTrId("overview_widget_inverter_title")
	icon.source: "qrc:/images/inverter_charger.svg"
	type: VenusOS.OverviewWidget_Type_VeBusDevice
	enabled: !!Global.inverterChargers.first
	quantityLabel.visible: false
	extraContentChildren: [
		Label {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
			}
			font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_maximumSize
			text: Global.system.systemStateToText(Global.system.state)
			wrapMode: Text.Wrap
		}
	]
	MouseArea {
		anchors.fill: parent
		onClicked: {
			const device = Global.inverterChargers.first
			if (device.serviceUid.indexOf('inverter') >= 0) {
				Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterPage.qml",
						{ "serviceUid": device.serviceUid, "title": device.name })
			} else {
				Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterChargerPage.qml", { "inverterCharger": device })
			}
		}
	}
}
