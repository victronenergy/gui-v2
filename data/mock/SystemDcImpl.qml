/*
** Copyright (C) 2025 Victron Energy B.V.
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

	function setGaugesValue(path, value) {
		MockManager.setValue(Services.settings.serviceUid + "/Settings/Gui/Gauges" + path, value)
	}
	function gaugesValue(path) {
		return MockManager.value(Services.settings.serviceUid + "/Settings/Gui/Gauges" + path)
	}

	VeQuickItem {
		id: gaugesAutoMax
		uid: Services.settings.serviceUid + "/Settings/Gui/Gauges/AutoMax"
	}

	// DC inputs: set the max DC-in power for the Brief/Overview gauge ranges.
	Instantiator {
		id: dcInputObjects

		function updateMaxPower() {
			let totalPower = 0
			for (let i = 0; i < count; ++i) {
				const power = objectAt(i)?.value ?? 0
				totalPower += power
			}
			root.setGaugesValue("/Dc/Input/Power/Max", Math.max(totalPower, root.gaugesValue("/Dc/Input/Power/Max") || 0))
		}

		active: gaugesAutoMax.value === 1
		model: FilteredServiceModel { serviceTypes: ["alternator", "fuelcell", "dcsource", "dcgenset"] }
		delegate: VeQuickItem {
			id: inputDelegate
			uid: model.uid + "/Dc/0/Power"
		}
		onObjectAdded: (index, dcInput) => {
			Qt.callLater(dcInputObjects.updateMaxPower)
		}
	}

	// DC Loads: set /Dc/System/Power to the total power of DC loads on the system.
	// Also set the max Brief/Overview gauge value for this, if required.
	Instantiator {
		id: dcLoads

		function updateTotals() {
			let totalPower = 0
			for (let i = 0; i < count; ++i) {
				totalPower += objectAt(i)?.power?.value ?? 0
			}
			root.setSystemValue("/Dc/System/Power", totalPower)

			if (gaugesAutoMax.value === 1) {
				root.setGaugesValue("/Dc/System/Power/Max",
						Math.max(totalPower, root.gaugesValue("/Dc/System/Power/Max") || 0))
			}
		}

		model: Services.system.dc.serviceModel
		delegate: QtObject {
			id: dcLoad

			required property string uid
			readonly property VeQuickItem power: VeQuickItem {
				uid: dcLoad.uid + "/Dc/0/Power"
				onValueChanged: Qt.callLater(dcLoads.updateTotals)
			}
		}
	}
	VeQuickItem {
		id: hasDcSystem
		uid: Services.settings.serviceUid + "/Settings/SystemSetup/HasDcSystem"
	}

	// Animate DC meters.
	Instantiator {
		model: FilteredServiceModel {
			serviceTypes: [
				"alternator",
				"battery",
				"solarcharger",
				"dcdc",
				"dcload",
				"dcsource",
				"dcsystem",
				"fuelcell",
				"vebus",
			]
		}
		delegate: Item {
			id: dcMeter

			required property string uid

			// Animate all common properties. Any properties which are not present on a particular
			// service will be ignored.
			MockDataRangeAnimator {
				id: socAnimator
				active: Global.mainView && Global.mainView.mainViewVisible
				maximumValue: 100
				stepSize: 8
				VeQuickItem { uid: dcMeter.uid + "/Soc" }
			}
			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				followSignOf: socAnimator.actualStepSizes[0] ?? NaN
				VeQuickItem { uid: dcMeter.uid + "/Dc/0/Power" }
				VeQuickItem { uid: dcMeter.uid + "/Dc/0/Current" }
			}
			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				VeQuickItem { uid: dcMeter.uid + "/Dc/0/Voltage" }
				VeQuickItem { uid: dcMeter.uid + "/Dc/0/Temperature" }
				VeQuickItem { uid: dcMeter.uid + "/Dc/In/P" }
				VeQuickItem { uid: dcMeter.uid + "/Dc/In/V" }
				VeQuickItem { uid: dcMeter.uid + "/Dc/In/I" }
			}
		}
	}

	// Emergency charge: when the emergency charge is activated, the AUX battery is used to charge
	// the starter battery for 15 minutes, then it goes to a "blocked" state for 5 minutes (during
	// which the vehicle can be started) to prevent the charger from drawing energy from the starter
	// battery or alternator.
	// For mock mode, just "charge" for 15 seconds and block for 5 seconds instead.
	Instantiator {
		model: FilteredDeviceModel {
			sorting: FilteredDeviceModel.Name
			serviceTypes: [ "alternator", "dcdc" ]
			childFilterIds: { "alternator": ["EmergencyCharge/Control"], "dcdc": ["EmergencyCharge/Control"] }
			childFilterFunction: (device, childItems) => {
				for (const name in childItems) {
					return !!childItems[name]
				}
				return false
			}
		}
		delegate: Item {
			id: emergencyChargeDelegate

			required property Device device

			VeQuickItem {
				id: emergencyChargeControl

				uid: emergencyChargeDelegate.device.serviceUid + "/EmergencyCharge/Control"
				onValueChanged: {
					if (value === VenusOS.EmergencyCharge_Control_Charging) {
						MockManager.setValue(emergencyChargeDelegate.device.serviceUid + "/Dc/In/I", Math.random())
						emergencyChargeStartTimer.updateCountdown(15)
					} else {
						MockManager.setValue(emergencyChargeDelegate.device.serviceUid + "/EmergencyCharge/ChargingCountdown", 0)
						MockManager.setValue(emergencyChargeDelegate.device.serviceUid + "/EmergencyCharge/BlockedCountdown", 0)
						emergencyChargeStartTimer.stop()
						emergencyChargeBlockedTimer.stop()
					}
				}
			}

			Timer {
				id: emergencyChargeStartTimer

				property int secondsRemaining

				function updateCountdown(s) {
					secondsRemaining = s
					MockManager.setValue(emergencyChargeDelegate.device.serviceUid + "/EmergencyCharge/ChargingCountdown", s)
					if (s <= 0) {
						stop()
						emergencyChargeBlockedTimer.updateCountdown(5)
					} else if (!running) {
						start()
					}
				}

				interval: 1000
				repeat: true
				onTriggered: {
					if (secondsRemaining > 0) {
						updateCountdown(secondsRemaining - 1)
					}
				}
			}

			Timer {
				id: emergencyChargeBlockedTimer

				property int secondsRemaining

				function updateCountdown(s) {
					secondsRemaining = s
					MockManager.setValue(emergencyChargeDelegate.device.serviceUid + "/EmergencyCharge/BlockedCountdown", s)
					if (s <= 0) {
						stop()
						emergencyChargeControl.setValue(VenusOS.EmergencyCharge_Control_Available)
					} else if (!running) {
						start()
					}
				}

				interval: 1000
				repeat: true
				onTriggered: {
					if (secondsRemaining > 0) {
						updateCountdown(secondsRemaining - 1)
					}
				}
			}
		}
	}
}
