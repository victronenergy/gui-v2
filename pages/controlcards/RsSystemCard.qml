/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property Device device

	icon.source: "qrc:/images/inverter_charger.svg"
	//: %1 = the inverter/charger name
	//% "Inverter / Charger (%1)"
	title.text: qsTrId("controlcard_rs_inverter_charger").arg(device.name)

	status.text: Global.system.systemStateToText(stateItem.value)

	VeQuickItem {
		id: stateItem
		uid: root.device.serviceUid + "/State"
	}

	Column {
		anchors {
			top: parent.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
			left: parent.left
			right: parent.right
		}

		ButtonControlValue {
			value: currentLimitDetails.currentLimit
			label.text: currentLimitDetails.title
			button.text: currentLimitDetails.currentLimitText
			enabled: Global.systemSettings.canAccess(VenusOS.User_AccessType_User)
			onClicked: currentLimitDetails.openDialog()

			RsSystemCurrentLimitDetails {
				id: currentLimitDetails
				bindPrefix: root.device.serviceUid
			}
		}

		ControlValue {
			width: parent.width
			implicitHeight: Theme.geometry_controlCard_mediumItem_height
			label.text: CommonWords.mode
			separator.visible: false
			contentRow.children: InverterChargerModeButton {
				anchors.verticalCenter: parent.verticalCenter
				width: Math.min(implicitWidth, Theme.geometry_veBusDeviceCard_modeButton_maximumWidth)
				serviceUid: root.device.serviceUid
			}
		}
	}
}
