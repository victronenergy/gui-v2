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

		ButtonControlValue {
			width: parent.width
			button.width: Math.max(button.implicitWidth, Theme.geometry_veBusDeviceCard_modeButton_maximumWidth)
			label.text: CommonWords.mode
			button.text: modeDialogLauncher.modeText
			separator.visible: false
			onClicked: modeDialogLauncher.openDialog()

			InverterModeDialogLauncher {
				id: modeDialogLauncher
				serviceUid: root.inverter.serviceUid
			}
		}
	}
}
