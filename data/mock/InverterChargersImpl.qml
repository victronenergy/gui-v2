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

			// Simulate manual equalization and interrupting it (see PageVeBusAdvanced.qml).
			// Writing /VebusSetChargeState requests a charge state change:
			//   1 = start equalization, which switches over to float once completed
			//   2 = interrupt equalization and restart absorption
			//   3 = interrupt equalization and go to float
			// After a brief delay, /VebusChargeState is updated and /VebusSetChargeState is reset to 0.
			VeQuickItem {
				id: vebusChargeState
				uid: veBusDelegate.serviceUid + "/VebusChargeState"
			}

			VeQuickItem {
				id: vebusSetChargeState
				uid: veBusDelegate.serviceUid + "/VebusSetChargeState"
				onValueChanged: {
					if (value >= 1 && value <= 3) {
						setChargeStateTimer.requestedState = value
						setChargeStateTimer.restart()
					}
				}
			}

			Timer {
				id: setChargeStateTimer

				property int requestedState

				interval: 1000
				onTriggered: {
					vebusSetChargeState.setValue(0)
					if (requestedState === 1) {
						vebusChargeState.setValue(VenusOS.VeBusDevice_ChargeState_Equalize)
						equalizeTimer.restart()
					} else if (vebusChargeState.value === VenusOS.VeBusDevice_ChargeState_Equalize) {
						equalizeTimer.stop()
						vebusChargeState.setValue(requestedState === 2
								? VenusOS.VeBusDevice_ChargeState_Absorption
								: VenusOS.VeBusDevice_ChargeState_Float)
					}
				}
			}

			// Equalization completes automatically if it is not interrupted.
			Timer {
				id: equalizeTimer
				interval: 20000
				onTriggered: vebusChargeState.setValue(VenusOS.VeBusDevice_ChargeState_Float)
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

		uid: Services.platform.serviceUid + "/Vebus/Interface/ttyS2/Action"
		onValueChanged: {
			if (valid && value !== VenusOS.VeBusDevice_Backup_Restore_Action_None) {
				MockManager.setValue(Services.platform.serviceUid + "/Vebus/Interface/ttyS2/Info", 10) // State = "Init"
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
				MockManager.setValue(Services.platform.serviceUid + "/Vebus/Interface/ttyS2/Notify", successCode)
			}
		}
	}
	VeQuickItem {
		id: availableBackupsItem
		uid: Services.platform.serviceUid + "/Vebus/Interface/ttyS2/AvailableBackups"
	}
	VeQuickItem {
		id: backupRestoreFileItem
		uid: Services.platform.serviceUid + "/Vebus/Interface/ttyS2/File"
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

	// Provide UI interaction when updating values on the Microgrid Droop parameters page.
	Instantiator {
		id: microgridParameters
		model: [
			"/MicroGrid/DroopModeParameters/P0",
			"/MicroGrid/DroopModeParameters/F0",
			"/MicroGrid/DroopModeParameters/FPDroop",
			"/MicroGrid/DroopModeParameters/Q0",
			"/MicroGrid/DroopModeParameters/U0",
			"/MicroGrid/DroopModeParameters/UQDroop",
			"/MicroGrid/DroopModeParameters/PMin",
			"/MicroGrid/DroopModeParameters/PMax",
			"/MicroGrid/DroopModeParameters/Qmin",
			"/MicroGrid/DroopModeParameters/Qmax",
		]
		delegate: VeQuickItem {
			uid: Services.system.veBus.serviceUid + modelData + "/Value"
			onValueChanged: MockManager.setValue(Services.system.veBus.serviceUid + modelData + "/Modified", 1)
		}
	}
	VeQuickItem {
		uid: Services.system.veBus.serviceUid + "/MicroGrid/DroopModeParameters/ActivateAndStore"
		onValueChanged: {
			if (valid && value === 1) {
				for (let i = 0; i < microgridParameters.model.length; ++i) {
					MockManager.setValue(Services.system.veBus.serviceUid + microgridParameters.model[i] + "/Modified", 0)
				}
				MockManager.setValue(Services.system.veBus.serviceUid + "/MicroGrid/DroopModeParameters/ActivateAndStore", 0)
			}
		}
	}

	// Animate ActiveIn parameters for Microgrid Droop parameters. Used to provide visual feedback for droop graphs
	MockDataRandomizer {
		active: Global.mainView && Global.mainView.mainViewVisible

		deltaLow: 1
		deltaHigh: 1
		minimumValue: 47.55
		maximumValue: 54.30

		VeQuickItem { uid: Services.system.veBus.serviceUid + "/Ac/ActiveIn/L1/F" }
	}
	MockDataRandomizer {
		active: Global.mainView && Global.mainView.mainViewVisible

		deltaLow: 2
		deltaHigh: 2
		minimumValue: 223.5
		maximumValue: 236.5

		VeQuickItem { uid: Services.system.veBus.serviceUid + "/Ac/ActiveIn/L1/V" }
	}
}
