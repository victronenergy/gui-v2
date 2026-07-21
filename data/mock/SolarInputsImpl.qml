/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function setSystemValue(path, value) {
		MockManager.setValue(Global.system.serviceUid + path, value)
	}
	function systemValue(path) {
		return MockManager.value(Global.system.serviceUid + path)
	}

	function setGaugesValue(path, value) {
		MockManager.setValue(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges" + path, value)
	}
	function gaugesValue(path) {
		return MockManager.value(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges" + path)
	}

	VeQuickItem {
		id: gaugesAutoMax
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/AutoMax"
	}

	// Set /Dc/Pv/<Power|Current> to the total charger power/current of PV chargers on the system.
	// Also set the PV max for the solar gauges on the Brief page.
	Instantiator {
		id: pvChargers

		function updateDcTotals() {
			let dcPower = NaN
			if (pvChargers.count) {
				for (let i = 0; i < count; ++i) {
					const charger = pvChargers.objectAt(i)
					if (charger) {
						dcPower = Units.sumRealNumbers(dcPower, charger.power)
					}
				}
			}
			root.setSystemValue("/Dc/Pv/Power", dcPower)
			root.setSystemValue("/Dc/Pv/Current", NaN)

			if (gaugesAutoMax.value === 1) {
				root.setGaugesValue("/Pv/Power/Max", Math.max(dcPower, root.gaugesValue("/Pv/Power/Max") || 0))
			}
		}

		model: Global.solarInputs.devices
		delegate: SolarDevice {
			required property BaseDevice device
			serviceUid: device.serviceUid
			onPowerChanged: Qt.callLater(pvChargers.updateDcTotals)
		}
		onCountChanged: Qt.callLater(updateDcTotals)
	}

	// Set /Ac/PvOnOutput to the total PV power/current of each phase of PV inverters on the system.
	// Computation runs entirely on the worker thread.
	MockPhaseSumCalculator {
		id: pvAcTotals
		targetPrefix: Global.system.serviceUid + "/Ac/PvOnOutput"
		sourcePhasePattern: "/Ac/L%1/Power"
		sourceCurrentPattern: "/Ac/L%1/Current"
	}

	Instantiator {
		id: pvInverters
		model: Global.solarInputs.pvInverterDevices
		delegate: QtObject {
			required property BaseDevice device
			readonly property string uid: device.serviceUid
			Component.onCompleted: pvAcTotals.addService(uid)
			Component.onDestruction: pvAcTotals.removeService(uid)
		}
	}

	// Animate PV chargers.
	Instantiator {
		model: Global.solarInputs.devices
		delegate: Item {
			id: pvCharger

			required property Device device
			readonly property string uid: device.serviceUid

			function updateTodaysYield() {
				let total = 0
				for (let i = 0; i < trackerObjects.count; ++i) {
					const tracker = trackerObjects.objectAt(i)
					total += tracker?.todaysYield ?? 0
				}
				MockManager.setValue(uid + "/History/Daily/0/Yield", total)
			}

			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				VeQuickItem { uid: pvCharger.uid + "/Pv/V" }
				VeQuickItem { uid: pvCharger.uid + "/Yield/Power" }
			}

			VeQuickItem {
				id: nrOfTrackers
				uid: pvCharger.uid + "/NrOfTrackers"
			}

			// Increase the yield and randomize the power/voltage.
			Instantiator {
				id: trackerObjects
				model: nrOfTrackers.value || null
				delegate: Item {
					required property int index
					readonly property real todaysYield: trackerYield.value || 0

					MockDataRandomizer {
						active: Global.mainView && Global.mainView.mainViewVisible
						VeQuickItem { uid: `${pvCharger.uid}/Pv/${index}/P` }
						VeQuickItem { uid: `${pvCharger.uid}/Pv/${index}/V` }
					}
					MockDataRangeAnimator {
						active: Global.mainView && Global.mainView.mainViewVisible
						stepSize: 0.005
						maximumValue: NaN

						VeQuickItem {
							id: trackerYield
							uid: `${pvCharger.uid}/History/Daily/0/Pv/${index}/Yield`
							onValueChanged: if (valid) pvCharger.updateTodaysYield()
						}
					}
				}
			}

			// If there are no trackers, increase the overall yield here.
			MockDataRangeAnimator {
				active: Global.mainView && Global.mainView.mainViewVisible && trackerObjects.count === 0
				stepSize: 0.005
				maximumValue: NaN

				VeQuickItem {
					uid: `${pvCharger.uid}/History/Daily/0/Yield`
				}
			}
		}
	}

	// Animate PV inverter values.
	Instantiator {
		model: FilteredServiceModel { serviceTypes: ["pvinverter"] }
		delegate: Item {
			id: pvInverter

			required property string uid

			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				totalTargetUid: pvInverter.uid + "/Ac/Power"
				derivedTargetUids: [
					pvInverter.uid + "/Ac/L1/Current",
					pvInverter.uid + "/Ac/L2/Current",
					pvInverter.uid + "/Ac/L3/Current"
				]
				derivedDivisorUids: [
					pvInverter.uid + "/Ac/L1/Voltage",
					pvInverter.uid + "/Ac/L2/Voltage",
					pvInverter.uid + "/Ac/L3/Voltage"
				]

				VeQuickItem { uid: pvInverter.uid + "/Ac/L1/Power" }
				VeQuickItem { uid: pvInverter.uid + "/Ac/L2/Power" }
				VeQuickItem { uid: pvInverter.uid + "/Ac/L3/Power" }
			}

			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				VeQuickItem { uid: pvInverter.uid + "/Ac/L1/Voltage" }
				VeQuickItem { uid: pvInverter.uid + "/Ac/L2/Voltage" }
				VeQuickItem { uid: pvInverter.uid + "/Ac/L3/Voltage" }
			}
		}
	}
}
