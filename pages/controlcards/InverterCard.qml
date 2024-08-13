/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property var inverter

	icon.source: "qrc:/images/inverter_charger.svg"
	//: %1 = the inverter name
	//% "Inverter (%1)"
	title.text: qsTrId("controlcard_inverter").arg(inverter.name)

	status.text: Global.system.systemStateToText(stateItem.value)

	VeQuickItem {
		id: stateItem
		uid: root.inverter.serviceUid + "/State"
	}

	Column {
		anchors {
			top: parent.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
			left: parent.left
			right: parent.right
		}

		ControlValue {
			width: parent.width
			implicitHeight: Theme.geometry_controlCard_mediumItem_height
			label.text: CommonWords.mode
			separator.visible: false
			contentRow.children: InverterChargerModeButton {
				anchors.verticalCenter: parent.verticalCenter
				width: Math.min(implicitWidth, Theme.geometry_veBusDeviceCard_modeButton_maximumWidth)
				serviceUid: root.inverter.serviceUid
			}
		}
	}
}
