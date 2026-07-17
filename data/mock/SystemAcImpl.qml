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
				root.setGaugesValue(minimumCurrentPath, Math.min(minimumCurrent, root.gaugesValue(minimumCurrentPath) || 0))
			}
		}
		onObjectAdded: (index, inputDelegate) => {
			inputDelegate.updateMinMaxCurrent()
		}
	}

	// AC loads: consumption is computed entirely on the worker thread via
	// MockConsumptionCalculator. The QML side only manages service discovery.
	MockConsumptionCalculator {
		id: consumptionCalculator
		systemUidPrefix: Global.system.serviceUid
	}

	Instantiator {
		id: acServiceObjects

		model: FilteredServiceModel { serviceTypes: ["vebus", "acsystem", "inverter", "charger"] }
		delegate: QtObject {
			id: acService

			required property int index
			required property string uid
			readonly property string serviceType: BackendConnection.serviceTypeFromUid(uid)

			Component.onCompleted: consumptionCalculator.addService(uid, serviceType, index)
			Component.onDestruction: consumptionCalculator.removeService(uid)
		}
	}

	// Consumption gauge AutoMax: track highest-seen consumption current and
	// write to gauge settings paths (read by SystemLoad.qml for gauge scaling).
	QtObject {
		id: gaugeMaxTracker

		function updateGaugeMax() {
			if (gaugesAutoMax.value !== 1) return
			let maxCurrent = 0
			for (const item of [_consL1Current, _consL2Current, _consL3Current]) {
				if (!isNaN(item.value)) maxCurrent = Math.max(maxCurrent, item.value)
			}
			const paths = [
				"/Ac/AcIn1/Consumption/Current/Max",
				"/Ac/AcIn2/Consumption/Current/Max",
				"/Ac/NoAcIn/Consumption/Current/Max",
			]
			for (const path of paths) {
				root.setGaugesValue(path, Math.max(maxCurrent, root.gaugesValue(path) || 0))
			}
		}

		property var _consL1Current: VeQuickItem { uid: Global.system.serviceUid + "/Ac/Consumption/L1/Current"; onValueChanged: gaugeMaxTracker.updateGaugeMax() }
		property var _consL2Current: VeQuickItem { uid: Global.system.serviceUid + "/Ac/Consumption/L2/Current"; onValueChanged: gaugeMaxTracker.updateGaugeMax() }
		property var _consL3Current: VeQuickItem { uid: Global.system.serviceUid + "/Ac/Consumption/L3/Current"; onValueChanged: gaugeMaxTracker.updateGaugeMax() }
	}

	// Animate AC input values.
	Instantiator {
		model: [Global.acInputs.input1Info, Global.acInputs.input2Info]
		delegate: Item {
			required property int index
			required property AcInputSystemInfo modelData
			readonly property AcInputSystemInfo acInputInfo: modelData
			readonly property AcInput acInput: Global.acInputs["input" + (index + 1)]
			readonly property string bindPrefix: acInput?._phaseMeasurements.bindPrefix ?? ""
			readonly property string voltageId: (acInput?.serviceType === "vebus" || acInput?.serviceType === "acsystem") ? "V" : "Voltage"
			readonly property string totalPowerUid: {
				if (!acInput) return ""
				if (acInput.serviceType === "vebus") return acInput.serviceUid + "/Ac/ActiveIn/P"
				if (acInput.serviceType === "acsystem") return acInput.serviceUid + "/Ac/In/%1/P".arg(index + 1)
				return ""
			}

			// For each phase, slide between the minimum and maximum current values.
			// Power = current * voltage is computed in the worker thread.
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
				derivedMultiplyTargetUids: bindPrefix ? [
					bindPrefix + "/L1/P",
					bindPrefix + "/L2/P",
					bindPrefix + "/L3/P"
				] : []
				derivedMultiplierUids: bindPrefix ? [
					bindPrefix + "/L1/" + voltageId,
					bindPrefix + "/L2/" + voltageId,
					bindPrefix + "/L3/" + voltageId
				] : []
				derivedMultiplyTotalTargetUid: totalPowerUid
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
				totalTargetUid: acObject.uid + "/Ac/Power"
				derivedTargetUids: [
					acObject.uid + "/Ac/L1/Current",
					acObject.uid + "/Ac/L2/Current",
					acObject.uid + "/Ac/L3/Current"
				]
				derivedDivisorUids: [
					acObject.uid + "/Ac/L1/Voltage",
					acObject.uid + "/Ac/L2/Voltage",
					acObject.uid + "/Ac/L3/Voltage"
				]

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

	FilteredServiceModel {
		id: hasAcLoadsModel
		serviceTypes: ["inverter", "charger", "evcharger", "acload", "heatpump", "vebus", "acsystem"]
		onCountChanged: Qt.callLater(updateHasAcLoads)
		Component.onCompleted: Qt.callLater(updateHasAcLoads)
		function updateHasAcLoads() {
			root.setSystemValue("/Ac/HasAcLoads", count === 0 ? 0 : 1)
		}
	}
}
