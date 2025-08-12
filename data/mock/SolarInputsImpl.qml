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
		MockManager.setValue(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges" + path, value)
	}
	function gaugesValue(path) {
		return MockManager.value("com.victronenergy.settings/Settings/Gui/Gauges" + path)
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
			if (model.count) {
				for (let i = 0; i < model.count; ++i) {
					const charger = model.deviceAt(i)
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
		delegate: QtObject {
			readonly property real power: modelData.power
			onPowerChanged: Qt.callLater(pvChargers.updateDcTotals)
		}
		onCountChanged: Qt.callLater(updateDcTotals)
	}

	// Set /Ac/PvOnOutput to the total PV power/current of each phase of PV inverters on the system.
	Instantiator {
		id: pvInverters

		function updateAcTotals() {
			let phaseIndex
			if (pvInverters.count) {
				let phaseCount = 0
				let phasePowers = []
				let phaseCurrents = []
				for (let i = 0; i < pvInverters.count; ++i) {
					const inverter = pvInverters.objectAt(i)
					if (inverter) {
						phaseCount = Math.max(phaseCount, inverter.phases.count)
						for (phaseIndex = 0; phaseIndex < inverter.phases.count; ++phaseIndex) {
							const phase = inverter.phases.get(phaseIndex)
							phasePowers[phaseIndex] = Units.sumRealNumbers(phasePowers[phaseIndex], phase.power)
							phaseCurrents[phaseIndex] = Units.sumRealNumbers(phaseCurrents[phaseIndex], phase.current)
						}
					}
				}
				root.setSystemValue("/Ac/PvOnOutput/NumberOfPhases", phaseCount)
				for (phaseIndex = 0; phaseIndex < phaseCount; ++phaseIndex) {
					root.setSystemValue("/Ac/PvOnOutput/L%1/Power".arg(phaseIndex + 1), phasePowers[phaseIndex])
					root.setSystemValue("/Ac/PvOnOutput/L%1/Current".arg(phaseIndex + 1), phaseCurrents[phaseIndex])
				}
				// Reset any other phase values from previous configurations.
				for (phaseIndex = phaseCount; phaseIndex < 3; ++phaseIndex) {
					root.setSystemValue("/Ac/PvOnOutput/L%1/Power".arg(phaseIndex + 1), phasePowers[phaseIndex])
					root.setSystemValue("/Ac/PvOnOutput/L%1/Current".arg(phaseIndex + 1), phaseCurrents[phaseIndex])
				}
			} else {
				root.setSystemValue("/Ac/PvOnOutput/NumberOfPhases", undefined)
				for (phaseIndex = 0; phaseIndex < 3; ++phaseIndex) {
					root.setSystemValue("/Ac/PvOnOutput/L%1/Power".arg(phaseIndex + 1), undefined)
					root.setSystemValue("/Ac/PvOnOutput/L%1/Current".arg(phaseIndex + 1), undefined)
				}
			}
		}

		model: Global.solarInputs.pvInverterDevices
		delegate: QtObject {
			readonly property real power: modelData.power
			readonly property var phases: modelData.phases
			onPowerChanged: Qt.callLater(pvInverters.updateAcTotals)
		}
		onCountChanged: Qt.callLater(updateAcTotals)
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
						VeQuickItem { uid: `${pvCharger.uid}/Pv/${index}/P` }
						VeQuickItem { uid: `${pvCharger.uid}/Pv/${index}/V` }
					}
					MockDataRangeAnimator {
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
				active: trackerObjects.count === 0
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
				onNotifyUpdate: (index, value) => {
					const voltage = MockManager.value(pvInverter.uid + "/Ac/L%1/Voltage".arg(index + 1))
					if (voltage > 0) {
						MockManager.setValue(pvInverter.uid + "/Ac/L%1/Current".arg(index + 1), value / voltage)
					}
				}
				onNotifyTotal: (totalPower) => { MockManager.setValue(pvInverter.uid + "/Ac/Power", totalPower) }

				VeQuickItem { uid: pvInverter.uid + "/Ac/L1/Power" }
				VeQuickItem { uid: pvInverter.uid + "/Ac/L2/Power" }
				VeQuickItem { uid: pvInverter.uid + "/Ac/L3/Power" }
			}

			MockDataRandomizer {
				VeQuickItem { uid: pvInverter.uid + "/Ac/L1/Voltage" }
				VeQuickItem { uid: pvInverter.uid + "/Ac/L2/Voltage" }
				VeQuickItem { uid: pvInverter.uid + "/Ac/L3/Voltage" }
			}
		}
	}
}
