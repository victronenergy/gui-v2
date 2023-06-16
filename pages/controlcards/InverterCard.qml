/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property var inverter

	property var _currentLimitDialog

	title.icon.source: "qrc:/images/inverter_charger.svg"
	//% "Inverter / Charger"
	title.text: qsTrId("controlcard_inverter_charger")

	// VE.Bus state is a subset of the aggregated system state, so use the same systemStateToText()
	// function to get a text description.
	status.text: Global.system.systemStateToText(inverter.state)

	Component {
		id: currentLimitDialogComponent

		NumberSelectorDialog {
			property var inputSettings
			property int inputIndex

			title: Global.acInputs.currentLimitTypeToText(inputSettings ? inputSettings.inputType : 0)
			suffix: "A"
			stepSize: 1
			to: 1000
			decimals: 1
			presets: root.inverter.ampOptions

			onAccepted: root.inverter.setCurrentLimit(inputIndex, value)
		}
	}

	Column {
		anchors {
			top: parent.status.bottom
			left: parent.left
			right: parent.right
		}
		Column {
			width: parent.width

			Repeater {
				id: currentLimitRepeater

				model: root.inverter.inputSettings

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
			button.width: Math.max(button.implicitWidth, Theme.geometry.inverterCard.modeButton.maximumWidth)
			label.text: CommonWords.mode
			button.text: Global.inverters.inverterModeToText(root.inverter.mode)
			enabled: root.inverter.modeAdjustable

			onClicked: {
				if (!_modeDialog) {
					_modeDialog = modeDialogComponent.createObject(Global.dialogLayer)
				}
				_modeDialog.mode = root.inverter.mode
				_modeDialog.open()
			}

			Component {
				id: modeDialogComponent

				InverterChargerModeDialog {
					onAccepted: {
						if (root.inverter.mode !== mode) {
							root.inverter.setMode(mode)
						}
					}
				}
			}
		}
	}
}
