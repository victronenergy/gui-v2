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
			button.text: Global.inverters.inverterModeToText(root.inverter.mode)
			enabled: root.inverter.modeAdjustable

			InverterModeDialogLauncher {
				id: modeDialogLauncher
				serviceUid: root.inverter.serviceUid
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
