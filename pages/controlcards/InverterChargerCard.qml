/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property var inverterCharger

	icon.source: "qrc:/images/inverter_charger.svg"
	//: %1 = the inverter/charger name
	//% "Inverter / Charger (%1)"
	title.text: qsTrId("controlcard_inverter_charger").arg(inverterCharger.name)

	// VE.Bus state is a subset of the aggregated system state, so use the same systemStateToText()
	// function to get a text description.
	status.text: Global.system.systemStateToText(inverterCharger.state)

	Column {
		anchors {
			top: parent.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
			left: parent.left
			right: parent.right
		}

		Column {
			width: parent ? parent.width : 0

			Repeater {
				model: AcInputSettingsModel {
					serviceUid: root.inverterCharger.serviceUid
					numberOfAcInputs: root.inverterCharger.numberOfAcInputs
				}
				delegate: ControlValue {
					width: parent.width
					implicitHeight: Theme.geometry_controlCard_mediumItem_height
					label.text: Global.acInputs.currentLimitTypeToText(modelData.inputType)
					contentRow.children: CurrentLimitButton {
						anchors.verticalCenter: parent.verticalCenter
						width: Math.min(implicitWidth, Theme.geometry_veBusDeviceCard_modeButton_maximumWidth)
						serviceUid: root.inverterCharger.serviceUid
						inputNumber: modelData.inputNumber
					}
				}
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
				serviceUid: root.inverterCharger.serviceUid
			}
		}
	}
}
