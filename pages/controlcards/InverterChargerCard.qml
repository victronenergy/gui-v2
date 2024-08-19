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

	VeQuickItem {
		id: bmsMode

		uid: root.inverterCharger.serviceUid + "/Devices/Bms/Version"
	}

	VeQuickItem {
		id: dmc

		uid: root.inverterCharger.serviceUid + "/Devices/Dmc/Version"
	}

	Component {
		id: currentLimitDialogComponent

		CurrentLimitDialog {
			presets: root.inverterCharger.ampOptions
			onAccepted: root.inverterCharger.setCurrentLimit(inputIndex, value)
		}
	}

	Column {
		anchors {
			top: parent.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
			left: parent.left
			right: parent.right
		}
		Column {
			width: parent.width

			Repeater {
				id: currentLimitRepeater

				model: root.inverterCharger.inputSettings

				delegate: ButtonControlValue {
					visible: label.text !== ""
					value: modelData.currentLimit
					label.text: Global.acInputs.currentLimitTypeToText(modelData.inputType)
					button.text: isNaN(value) ? "--" : Units.getCombinedDisplayText(VenusOS.Units_Amp, value)
					onClicked: {
						if (!modelData.currentLimitAdjustable) {
							if (dmc.isValid) {
								Global.showToastNotification(VenusOS.Notification_Info, CommonWords.noAdjustableByDmc, 5000)
								return
							}
							if (bmsMode.isValid) {
								Global.showToastNotification(VenusOS.Notification_Info, CommonWords.noAdjustableByBms, 5000)
								return
							}
							Global.showToastNotification(VenusOS.Notification_Info, CommonWords.noAdjustableTextByConfig, 5000)
							return
						}
						Global.dialogLayer.open(currentLimitDialogComponent,
								{ inputType: modelData.inputType, inputIndex: model.index, value: modelData.currentLimit })
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
				text: Global.inverterChargers.inverterChargerModeToText(root.inverterCharger.mode)
			}
		}
	}
}
