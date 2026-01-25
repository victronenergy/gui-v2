/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function setSystemValue(path, value) {
		MockManager.setValue("com.victronenergy.system" + path, value)
	}
	function systemValue(path) {
		return MockManager.value("com.victronenergy.system" + path)
	}

	FilteredDeviceModel {
		id: inverterChargerModel
		serviceTypes: ["vebus", "acsystem", "inverter", "charger"]
	}

	// Set /SystemState/State to the state of the inverter/charger with the lowest instance.
	// This isn't necessarily correct, but it will do for mock mode.
	VeQuickItem {
		uid: inverterChargerModel.firstObject
			 ? inverterChargerModel.firstObject.serviceUid + "/State"
			 : ""
		onValueChanged: root.setSystemValue("/SystemState/State", value ?? VenusOS.System_State_Off)
	}

	// Set /Dc/InverterCharger/Power to the total power of inverter/chargers on the system.
	Instantiator {
		id: inverterChargerObjects
		function updateTotal() {
			let totalPower = NaN
			for (let i = 0; i < count; ++i) {
				totalPower = Units.sumRealNumbers(totalPower, objectAt(i)?.power ?? 0)
			}
			root.setSystemValue("/Dc/InverterCharger/Power", totalPower)
		}

		model: inverterChargerModel
		delegate: VeQuickItem {
			required property Device device
			uid: device.serviceUid + "/Dc/0/Power"
			onValueChanged: Qt.callLater(inverterChargerObjects.updateTotal)
		}
	}

	FilteredDeviceModel {
		id: vebusModel
		serviceTypes: ["vebus"]
	}

	// Set /VebusService to name of the first vebus service found on the system.
	Connections {
		target: vebusModel
		function onFirstObjectChanged() {
			const device = vebusModel.firstObject
			if (device) {
				// Write uid like "com.victronenergy.vebus.tty0", without "mock/" prefix
				const uid = device.serviceUid.substring(BackendConnection.uidPrefix().length + 1)
				root.setSystemValue("/VebusService", uid)
				root.setSystemValue("/VebusInstance", device.deviceInstance)
			} else {
				root.setSystemValue("/VebusService", "")
				root.setSystemValue("/VebusService", undefined)
			}
		}
	}

	// Simulate various vebus actions to make the UI more responsive when changing vebus settings.
	Instantiator {
		model: vebusModel
		delegate: Item {
			id: veBusDelegate

			required property Device device
			readonly property string serviceUid: device.serviceUid

			// When /VebusSetChargeState=1, cycle between equalize and absorption change states.
			VeQuickItem {
				uid: veBusDelegate.serviceUid + "/VebusSetChargeState"
				onValueChanged: {
					if (value === 1) {
						equalizeTimer.start()
					}
				}

				property Timer equalizeTimer: Timer {
					interval: 5000
					repeat: true
					onTriggered: {
						switch (parent.value) {
						case VenusOS.VeBusDevice_ChargeState_Absorption:
							parent.setValue(VenusOS.VeBusDevice_ChargeState_Equalize)
							break
						default:
							parent.setValue(VenusOS.VeBusDevice_ChargeState_Absorption)
							stop()
							break
						}
					}
				}
			}

			// When /RedetectSystem or /SystemReset features are triggered, clear these values after a delay
			// so that the UI buttons are available again.
			VeQuickItem {
				uid: veBusDelegate.serviceUid + "/RedetectSystem"
				onValueChanged: if (value === 1) redetectTimer.start()

				property Timer redetectTimer: Timer {
					interval: 1000
					onTriggered: parent.setValue(0)
				}
			}
			VeQuickItem {
				uid: veBusDelegate.serviceUid + "/SystemReset"
				onValueChanged: if (value === 1) resetSystemTimer.start()

				property Timer resetSystemTimer: Timer {
					interval: 1000
					onTriggered: parent.setValue(0)
				}
			}
		}
	}

	// When backup/restore features are triggered, mimic a successful action that is finished after
	// a brief delay.
	VeQuickItem {
		id: _backupRestoreAction

		uid: Global.venusPlatform.serviceUid + "/Vebus/Interface/ttyS2/Action"
		onValueChanged: {
			if (valid && value !== VenusOS.VeBusDevice_Backup_Restore_Action_None) {
				MockManager.setValue(Global.venusPlatform.serviceUid + "/Vebus/Interface/ttyS2/Info", 10) // State = "Init"
				_actionResetTimer.restart()
			}
		}

		readonly property Timer _actionResetTimer: Timer {
			interval: 2000
			onTriggered: {
				let successCode = _backupRestoreAction.value
				const backupName = backupRestoreFileItem.value || ""
				let backupList = availableBackupsItem.value || ""
				backupList = backupList ? JSON.parse(backupList) : []

				switch (_backupRestoreAction.value) {
				case VenusOS.VeBusDevice_Backup_Restore_Action_Backup:
					backupList.push(backupName + "-ttyS2")
					successCode = 1
					break
				case VenusOS.VeBusDevice_Backup_Restore_Action_Restore:
					backupList.splice(backupList.indexOf(backupName + "-ttyS2"), 1)
					successCode = 2
					break
				case VenusOS.VeBusDevice_Backup_Restore_Action_Delete:
					backupList.splice(backupList.indexOf(backupName + "-ttyS2"), 1)
					successCode = 3
					break
				}
				availableBackupsItem.setValue(JSON.stringify(backupList))
				_backupRestoreAction.setValue(VenusOS.VeBusDevice_Backup_Restore_Action_None)
				MockManager.setValue(Global.venusPlatform.serviceUid + "/Vebus/Interface/ttyS2/Notify", successCode)
			}
		}
	}
	VeQuickItem {
		id: availableBackupsItem
		uid: Global.venusPlatform.serviceUid + "/Vebus/Interface/ttyS2/AvailableBackups"
	}
	VeQuickItem {
		id: backupRestoreFileItem
		uid: Global.venusPlatform.serviceUid + "/Vebus/Interface/ttyS2/File"
	}

	// Animate AC-out values; AC-in values are already animated by SystemAcImpl.qml, and DC values
	// by SystemDcImpl.qml.
	Instantiator {
		model: inverterChargerModel
		delegate: Item {
			id: inverterCharger

			required property Device device
			readonly property string uid: device.serviceUid

			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				onNotifyUpdate: (index, value) => {
					const voltage = MockManager.value(inverterCharger.uid + "/Ac/Out/L%1/V".arg(index + 1))
					if (voltage > 0) {
						MockManager.setValue(inverterCharger.uid + "/Ac/L%1/I".arg(index + 1), value / voltage)
					}
				}
				onNotifyTotal: (totalPower) => { MockManager.setValue(uid + "/Ac/Out/P", totalPower) }

				VeQuickItem { uid: inverterCharger.uid + "/Ac/Out/L1/P" }
				VeQuickItem { uid: inverterCharger.uid + "/Ac/Out/L2/P" }
				VeQuickItem { uid: inverterCharger.uid + "/Ac/Out/L3/P" }
			}
			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				VeQuickItem { uid: inverterCharger.uid + "/Ac/Out/L1/V" }
				VeQuickItem { uid: inverterCharger.uid + "/Ac/Out/L2/V" }
				VeQuickItem { uid: inverterCharger.uid + "/Ac/Out/L3/V" }
			}
		}
	}

	// Animate Microgrid Droop parameters. Used to provide visual feedback for droop graphs
	// NB/ modified values are not animated
	MockDataRandomizer {
		active: true

		minimumValue: 55
		maximumValue: 68

		VeQuickItem { uid: Global.system.veBus.serviceUid + "/MicroGrid/DroopModeParameters/F0/Value" }
	}
	MockDataRandomizer {
		active: true

		minimumValue: 225
		maximumValue: 285

		VeQuickItem { uid: Global.system.veBus.serviceUid + "/MicroGrid/DroopModeParameters/U0/Value" }
	}
}
