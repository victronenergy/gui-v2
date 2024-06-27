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

		ButtonControlValue {
			width: parent.width
			button.width: Math.max(button.implicitWidth, Theme.geometry_veBusDeviceCard_modeButton_maximumWidth)
			label.text: CommonWords.mode
			button.text: modeDetails.modeText
			enabled: Global.systemSettings.canAccess(VenusOS.User_AccessType_User)
			separator.visible: false
			onClicked: modeDetails.openDialog()

			RsSystemModeDetails {
				id: modeDetails
				bindPrefix: root.device.serviceUid
			}
		}
	}
}
