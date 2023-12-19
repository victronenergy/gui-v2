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

	//% "Backup complete"
	readonly property string backup_complete: qsTrId("backup_complete")
	//% "Restore complete"
	readonly property string restore_complete: qsTrId("restore_complete")
	//% "Backup"
	readonly property string backup: qsTrId("backup")
	//% "Restore"
	readonly property string restore: qsTrId("restore")
	//% "Backing up..."
	readonly property string backup_in_progress: qsTrId("backup_in_progress")
	//% "Restoring..."
	readonly property string restore_in_progress: qsTrId("restore_in_progress")
	//% "Click to backup"
	readonly property string backup_prompt: qsTrId("backup_prompt")
	//% "Click to restore"
	readonly property string restore_prompt: qsTrId("restore_prompt")

	property DataPoint _mk2Connection: DataPoint {
		source: inverter.serviceUid + "/Interfaces/Mk2/Connection"
	}
	property DataPoint _backuprestoreSerial: DataPoint {
		source: "com.victronenergy.backuprestore/Quattromulti/Args/Serial"
	}
	property DataPoint _backuprestoreState: DataPoint {
		source: "com.victronenergy.backuprestore/Quattromulti/State"
		onValueChanged: {
			if (value === 3) Global.showToastNotification(VenusOS.Notification_Warning, _backuprestoreError.value, 10000)
			else if (value === 4) Global.showToastNotification(VenusOS.Notification_Info, backup_complete, 10000)
			else if (value === 5) Global.showToastNotification(VenusOS.Notification_Info, restore_complete, 10000)
		}
	}
	property DataPoint _backupName: DataPoint {
		source: "com.victronenergy.backuprestore/Quattromulti/Backup/Name"
	}
	property DataPoint _backuprestoreError: DataPoint {
		source: "com.victronenergy.backuprestore/Quattromulti/Error"
	}


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
			topMargin: Theme.geometry_controlCard_status_bottomMargin
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
						root._currentLimitDialog.openDialog(modelData, model.index)
					}
				}
			}
		}

		VeBusDeviceModeButton {
			veBusDevice: root.veBusDevice
			sourceComponent: Component {
				ButtonControlValue {
					width: parent.width
					button.width: Math.max(button.implicitWidth, Theme.geometry_veBusDeviceCard_modeButton_maximumWidth)
					label.text: CommonWords.mode
					button.text: Global.veBusDevices.modeToText(root.veBusDevice.mode)
					separator.visible: false
				}
			}
		}

		ButtonControlValue {
			width: parent.width
			button.width: Math.max(button.implicitWidth, Theme.geometry.inverterCard.modeButton.maximumWidth)
			label.text: backup
			button.text: (_backuprestoreState.value === 1)? backup_in_progress:backup_prompt
			visible: _backuprestoreState.valid
			enabled: (_backuprestoreState.value === 0)
			onClicked: {
				_backuprestoreSerial.setValue(_mk2Connection.value.split("/").pop())
				_backuprestoreState.setValue(1)
			}
		}

		ButtonControlValue {
			width: parent.width
			button.width: Math.max(button.implicitWidth, Theme.geometry.inverterCard.modeButton.maximumWidth)
			label.text: restore + " - " + _backupName.value
			button.text: (_backuprestoreState.value === 2)? restore_in_progress:restore_prompt
			visible: _backuprestoreState.valid && _backupName.valid
			enabled: (_backuprestoreState.value === 0)
			onClicked: {
				_backuprestoreSerial.setValue(_mk2Connection.value.split("/").pop())
				_backuprestoreState.setValue(2)
			}
		}
	}
}
