/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property var veBusDevice

	property var _currentLimitDialog

	title.icon.source: "qrc:/images/inverter_charger.svg"
	//% "Inverter / Charger"
	title.text: qsTrId("controlcard_inverter_charger")

	// VE.Bus state is a subset of the aggregated system state, so use the same systemStateToText()
	// function to get a text description.
	status.text: Global.system.systemStateToText(veBusDevice.state)

	Component {
		id: currentLimitDialogComponent

		CurrentLimitDialog {
			presets: root.veBusDevice.ampOptions
			onAccepted: root.veBusDevice.setCurrentLimit(inputIndex, value)
		}
	}

	Column {
		anchors {
			top: parent.status.bottom
			topMargin: Theme.geometry.controlCard.status.bottomMargin
			left: parent.left
			right: parent.right
		}
		Column {
			width: parent.width

			Repeater {
				id: currentLimitRepeater

				model: root.veBusDevice.inputSettings

				delegate: ButtonControlValue {
					visible: label.text !== ""
					value: modelData.currentLimit
					label.text: Global.acInputs.currentLimitTypeToText(modelData.inputType)
					enabled: modelData.currentLimitAdjustable
					//% "%1 A"
					button.text: qsTrId("amps").arg(value)   // TODO use UnitConverter.convertToString() or unitToString() instead
					onClicked: {
						if (!root._currentLimitDialog) {
							root._currentLimitDialog = currentLimitDialogComponent.createObject(Global.dialogLayer)
						}
						root._currentLimitDialog.inputSettings = modelData
						root._currentLimitDialog.inputIndex = model.index
						root._currentLimitDialog.value = modelData.currentLimit
						root._currentLimitDialog.open()
					}
				}
			}
		}
		ButtonControlValue {
			property var _modeDialog

			width: parent.width
			button.width: Math.max(button.implicitWidth, Theme.geometry.veBusDeviceCard.modeButton.maximumWidth)
			label.text: CommonWords.mode
			button.text: Global.veBusDevices.modeToText(root.veBusDevice.mode)
			enabled: root.veBusDevice.modeAdjustable
			separator.visible: false

			onClicked: {
				if (!_modeDialog) {
					_modeDialog = modeDialogComponent.createObject(Global.dialogLayer)
				}
				_modeDialog.mode = root.veBusDevice.mode
				_modeDialog.open()
			}

			Component {
				id: modeDialogComponent

				InverterChargerModeDialog {
					isMulti: root.veBusDevice.isMulti
					onAccepted: {
						if (root.veBusDevice.mode !== mode) {
							root.veBusDevice.setMode(mode)
						}
					}
				}
			}
		}
	}
}
