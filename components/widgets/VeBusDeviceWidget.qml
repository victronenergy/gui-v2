/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "Inverter / Charger"
	title: qsTrId("overview_widget_inverter_title")
	icon.source: "qrc:/images/inverter_charger.svg"
	type: VenusOS.OverviewWidget_Type_VeBusDevice
	enabled: Global.veBusDevices.model.count > 0
	quantityLabel.visible: false
	extraContent.children: [
		Label {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
			}
			font.pixelSize: Theme.font.overviewPage.widget.quantityLabel.maximumSize
			text: Global.system.systemStateToText(Global.system.state)
			wrapMode: Text.Wrap
		}
	]
	MouseArea {
		anchors.fill: parent
		onClicked: Global.pageManager.pushPage("/pages/vebusdevice/VeBusDeviceListPage.qml")
	}
}
