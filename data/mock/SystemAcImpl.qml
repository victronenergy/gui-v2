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

	// AC inputs: on initialization, set the AC input current min/max for the Brief/Overview gauges.
	// If /CurrentLimit is available, use that as the maximum current, otherwise use the max value
	// of the currents found for the inputs's phases. If no max is found, hardcode this to 50.
	// The minimum is 0, or (max * -1) if grid feed-in is available.
	Instantiator {
		active: gaugesAutoMax.value === 1
		model: 2
		delegate: QtObject {
			id: acInputDelegate

			required property int index
			readonly property AcInput acInput: Global.acInputs["input" + (index + 1)]

			function updateMinMaxCurrent() {
				if (!acInput) {
					return
				}
				const objAcConn = acInput._phaseMeasurements
				let maximumCurrent = MockManager.value(objAcConn.bindPrefix + "/CurrentLimit")
				if (isNaN(maximumCurrent)) {
					for (let i = 0; i < objAcConn.phaseCount; ++i) {
						// objAcConn
						const current = objAcConn["currentL" + (i+1)].value
						if (!isNaN(current)) {
							if (isNaN(maximumCurrent)) {
								maximumCurrent = current
							} else {
								maximumCurrent = Math.max(current, maximumCurrent)
							}
						}

					}
				}
				if (isNaN(maximumCurrent)) {
					maximumCurrent = 50
				}
				const maximumCurrentPath = "/Ac/In/" + acInputDelegate.index + "/Current/Max"
				root.setGaugesValue(maximumCurrentPath, Math.max(maximumCurrent, root.gaugesValue(maximumCurrentPath) || 0))

				const minimumCurrent = Global.system.feedbackEnabled ? maximumCurrent * -1 : 0
				const minimumCurrentPath = "/Ac/In/" + acInputDelegate.index + "/Current/Min"
				root.setGaugesValue(minimumCurrentPath, Math.min(minimumCurrent, root.gaugesValue(minimumCurrent) || 0))
			}
		}
		onObjectAdded: (index, inputDelegate) => {
			inputDelegate.updateMinMaxCurrent()
		}
	}

	// AC loads: set /Ac/Consumption, /Ac/ConsumptionOnOutput and /Ac/ConsumptionOnInput values
	// using the AC-in and AC-out data from all inverter/chargers. This is a simple and incomplete
	// way to get some numbers to show up for AC Loads and Essential Loads in mock mode.
	// - ConsumptionOnOutput = essential loads
	// - ConsumptionOnInput = AC loads
	// - Consumption = combined loads
	Instantiator {
		id: acServiceObjects

		function updateConsumption() {
			let maxPhaseIndex = 0
			const updateGaugeRanges = gaugesAutoMax.value === 1
			let acIn1MaxCurrent = 0
			let acIn2MaxCurrent = 0
			let noAcInMaxCurrent = 0

			for (let phaseIndex = 0; phaseIndex < 3; ++phaseIndex) {
				let phaseAcInPower = NaN
				let phaseAcInCurrent = NaN
				let phaseAcOutPower = NaN
				let phaseAcOutCurrent = NaN
				for (let objectIndex = 0; objectIndex < count; ++objectIndex) {
					const acService = objectAt(objectIndex)
					if (!acService) {
						continue
					}
					phaseAcInPower = Units.sumRealNumbers(phaseAcInPower, acService.acIn["powerL" + (phaseIndex + 1)].value)
					phaseAcInCurrent = Units.sumRealNumbers(phaseAcInCurrent, acService.acIn["currentL" + (phaseIndex + 1)].value)
					phaseAcOutPower = Units.sumRealNumbers(phaseAcOutPower, acService.acOut["powerL" + (phaseIndex + 1)].value)
					phaseAcOutCurrent = Units.sumRealNumbers(phaseAcOutCurrent, acService.acOut["currentL" + (phaseIndex + 1)].value)
					if (updateGaugeRanges) {
						const inputCurrent = (phaseAcInCurrent || 0) + (phaseAcOutCurrent || 0)
						if (acService.activeInput === 1) {
							acIn1MaxCurrent = Math.max(acIn1MaxCurrent, inputCurrent)
						} else if (acService.activeInput === 2) {
							acIn2MaxCurrent = Math.max(acIn2MaxCurrent, inputCurrent)
						} else {
							noAcInMaxCurrent = Math.max(noAcInMaxCurrent, inputCurrent)
						}
					}
				}

				// This is not how consumption on input is calculated on a real system, but it gives
				// us some numbers to show in mock mode.
				const consumptionOnInputPower = Math.max(0, phaseAcInPower - phaseAcOutPower)
				const consumptionOnInputCurrent = Math.max(0, phaseAcInCurrent - phaseAcOutCurrent)
				const consumptionOnOutputPower = phaseAcOutPower
				const consumptionOnOutputCurrent = phaseAcOutCurrent
				const systemValues = [
					{ path: "/Ac/ConsumptionOnInput/L%1/Power".arg(phaseIndex + 1), value: consumptionOnInputPower },
					{ path: "/Ac/ConsumptionOnInput/L%1/Current".arg(phaseIndex + 1), value: consumptionOnInputCurrent },
					{ path: "/Ac/ConsumptionOnOutput/L%1/Power".arg(phaseIndex + 1), value: consumptionOnOutputPower },
					{ path: "/Ac/ConsumptionOnOutput/L%1/Current".arg(phaseIndex + 1), value: consumptionOnOutputCurrent },
					{ path: "/Ac/Consumption/L%1/Power".arg(phaseIndex + 1), value: Units.sumRealNumbers(consumptionOnInputPower, consumptionOnOutputPower) },
					{ path: "/Ac/Consumption/L%1/Current".arg(phaseIndex + 1), value: Units.sumRealNumbers(consumptionOnInputCurrent, consumptionOnOutputCurrent) },
				]
				for (const systemValue of systemValues) {
					// If a value is available, or changing from an invalid value, then update the
					// consumption value for this phase.
					if (!isNaN(systemValue.value) || !isNaN(root.systemValue(systemValue.path))) {
						root.setSystemValue(systemValue.path, systemValue.value)
						maxPhaseIndex = Math.max(maxPhaseIndex, phaseIndex)
					}
				}
			}

			root.setSystemValue("/Ac/ConsumptionOnOutput/NumberOfPhases", maxPhaseIndex + 1)
			root.setSystemValue("/Ac/ConsumptionOnInput/NumberOfPhases", maxPhaseIndex + 1)
			root.setSystemValue("/Ac/Consumption/NumberOfPhases", maxPhaseIndex + 1)

			// Update the AC load current min/max for the Brief/Overview gauge ranges, to the
			// highest-seen AC out values.
			if (updateGaugeRanges) {
				const gaugeValues = [
					{ path: "/Ac/AcIn1/Consumption/Current/Max", value: acIn1MaxCurrent },
					{ path: "/Ac/AcIn2/Consumption/Current/Max", value: acIn2MaxCurrent },
					{ path: "/Ac/NoAcIn/Consumption/Current/Max", value: noAcInMaxCurrent },
				]
				for (const gaugeValue of gaugeValues) {
					const newMax = Math.max(gaugeValue.value, root.gaugesValue(gaugeValue.path) || 0)
					root.setGaugesValue(gaugeValue.path, newMax)
				}
			}
		}

		model: FilteredServiceModel { serviceTypes: ["vebus", "acsystem", "inverter", "charger"] }
		delegate: QtObject {
			id: acService

			required property string uid
			readonly property string serviceType: BackendConnection.serviceTypeFromUid(uid)
			readonly property int activeInput: _activeInput.value === VenusOS.AcInputs_InputSource_Inverting ? -1
						: !_activeInput.valid ? 1
						: _activeInput.value + 1
			property bool completed

			// For simplicity, attempt to fetch L1/L2/L3 in/out data, regardless of the actual
			// number of phases on the device.
			readonly property ObjectAcConnection acIn: ObjectAcConnection {
				powerKey: "P"
				currentKey: "I"
				bindPrefix: acService.serviceType === "vebus" ? acService.uid + "/Ac/ActiveIn"
					: acService.serviceType === "acsystem" ? acService.uid + "/Ac/In/%1".arg(activeInput.value + 1)
					: acService.serviceType === "charger" ? acService.uid + "/Ac/In"
					: "" // no AC-in for inverters
				onPowerChanged: {
					if (acService.completed) {
						Qt.callLater(acServiceObjects.updateConsumption)
					}
				}
			}
			readonly property ObjectAcConnection acOut: ObjectAcConnection {
				powerKey: "P"
				currentKey: "I"
				bindPrefix: acService.serviceType === "charger" ? "" : acService.uid + "/Ac/Out"
				onPowerChanged: {
					if (acService.completed) {
						Qt.callLater(acServiceObjects.updateConsumption)
					}
				}
			}
			readonly property VeQuickItem _activeInput: VeQuickItem {
				uid: acService.serviceType === "vebus" || acService.serviceType === "acsystem"
					 ? acService.uid + "/Ac/ActiveIn/ActiveInput"
					 : ""
			}
		}
		onObjectAdded: (index, acService) => {
			Qt.callLater(acServiceObjects.updateConsumption)
			acService.completed = true
		}
	}

	// Animate AC input values.
	Instantiator {
		model: [Global.acInputs.input1Info, Global.acInputs.input2Info]
		delegate: Item {
			required property int index
			required property AcInputSystemInfo modelData
			readonly property AcInputSystemInfo acInputInfo: modelData
			readonly property AcInput acInput: Global.acInputs["input" + (index + 1)]

			// For each phase, slide between the minimum and maximum current values.
			MockDataRangeAnimator {
				active: Global.mainView && Global.mainView.mainViewVisible
				maximumValue: acInputInfo.maximumCurrent
				minimumValue: acInputInfo.minimumCurrent
				stepSize: (maximumValue - minimumValue) / 10
				dataItems: [
					acInput?._phaseMeasurements.currentL1 ?? null,
					acInput?._phaseMeasurements.currentL2 ?? null,
					acInput?._phaseMeasurements.currentL3 ?? null,
				]

				onNotifyTotal: {
					if (!acInput || !acInput._phaseMeasurements.bindPrefix || index < 0) {
						return
					}
					// When the phase current changes, update the phase power as well.
					let totalPower = 0
					for (let phaseIndex = 0; phaseIndex < acInput.phases.count; ++phaseIndex) {
						const current = dataItems[phaseIndex].value
						const voltageId = acInput.serviceType === "vebus" || acInput.serviceType === "acsystem" ? "V" : "Voltage"
						const voltage = MockManager.value(`${acInput._phaseMeasurements.bindPrefix}/L${phaseIndex + 1}/${voltageId}`)
						const power = current * voltage
						acInput._phaseMeasurements["powerL" + (phaseIndex+1)].setValue(power)
						totalPower += power
					}
					if (acInput.serviceType === "vebus") {
						MockManager.setValue(acInput.serviceUid + "/Ac/ActiveIn/P", totalPower)
					} else if (acInput.serviceType === "acsystem") {
						const activeInput = MockManager.value(acInput.serviceUid + "/Ac/ActiveIn/ActiveInput")
						MockManager.setValue(acInput.serviceUid + "/Ac/%1/P".arg(activeInput + 1), totalPower)
					}
				}
			}
		}
	}

	// Animate AC values for select energy meters. Grid/genset are already animated if they are the
	// active AC input, and pvinverter/evcharger are already animated elsewhere.
	Instantiator {
		model: FilteredServiceModel { serviceTypes: ["acload", "heatpump"] }
		delegate: Item {
			id: acObject

			required property string uid

			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				onNotifyUpdate: (index, value) => {
					const voltage = MockManager.value(acObject.uid + "/Ac/L%1/Voltage".arg(index + 1))
					if (voltage > 0) {
						MockManager.setValue(acObject.uid + "/Ac/L%1/Current".arg(index + 1), value / voltage)
					}
				}
				onNotifyTotal: (totalPower) => { MockManager.setValue(uid + "/Ac/Power", totalPower) }

				VeQuickItem { uid: acObject.uid + "/Ac/L1/Power" }
				VeQuickItem { uid: acObject.uid + "/Ac/L2/Power" }
				VeQuickItem { uid: acObject.uid + "/Ac/L3/Power" }
			}
			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				VeQuickItem { uid: acObject.uid + "/Ac/L1/Voltage" }
				VeQuickItem { uid: acObject.uid + "/Ac/L2/Voltage" }
				VeQuickItem { uid: acObject.uid + "/Ac/L3/Voltage" }
			}
		}
	}
}
