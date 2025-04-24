/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function setMockValue(path, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.system" + path, value)
	}

	function populate() {
		setMockValue("/SystemState/State", VenusOS.System_State_AbsorptionCharging)
		setAcLoadPhaseCount(3)
	}

	function setAcLoadPhaseCount(phaseCount) {
		setMockValue("/Ac/Consumption/NumberOfPhases", phaseCount)
		setMockValue("/Ac/ConsumptionOnInput/NumberOfPhases", phaseCount)
		setMockValue("/Ac/ConsumptionOnOutput/NumberOfPhases", phaseCount)
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetShowInputLoadsRequested(showInputLoads) {
			if (showInputLoads) {
				root.setMockValue("/Ac/Grid/DeviceType", 1)  // Set to any valid value for testing
				Global.mockDataSimulator.setMockValue(Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasAcOutSystem", 1)
			} else {
				root.setMockValue("/Ac/Grid/DeviceType", undefined)
				Global.mockDataSimulator.setMockValue(Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasAcOutSystem", 0)
			}
		}

		function onSetSystemRequested(config) {
			root.setMockValue("/SystemState/State", config?.state || VenusOS.System_State_Off)

			if (config) {
				if (config.ac) {
					randomizeAcValues.restart()  // immediately provide valid values for the new configuration
					root.setAcLoadPhaseCount(config.ac.phaseCount || 3)
				} else {
					randomizeAcValues.running = false
					root.setAcLoadPhaseCount(0)
				}
				if (config.showInputLoads !== undefined) {
					onSetShowInputLoadsRequested(config.showInputLoads)
				}
				if (config.hasAcOutSystem !== undefined) {
					Global.mockDataSimulator.setMockValue(Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasAcOutSystem", config.hasAcOutSystem ? 1 : 0)
				}
			}
		}
	}

	//--- AC data ---

	property Timer randomizeAcValues: Timer {
		running: Global.mockDataSimulator.timersActive && _maximumAcCurrent.valid
		interval: 2000
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			// Use some wild fluctuations that can be seen in the Brief side panel graph
			const randomIndex = Math.floor(Math.random() * Global.system.load.ac.phases.count)
			const currentLimit = Global.acInputs.highlightedInput?.inputInfo === Global.acInputs.input1Info ? _input1MaximumAcCurrent.value
					: Global.acInputs.highlightedInput?.inputInfo === Global.acInputs.input2Info ? _input2MaximumAcCurrent.value
					: _maximumAcCurrent.value
			const current = Math.random() * currentLimit
			const power = current * 10

			// Consumption = ConsumptionOnInput + ConsumptionOnOutput
			const keys = { "Consumption" : 1 , "ConsumptionOnInput" : 0.75, "ConsumptionOnOutput": 0.25 }
			for (const key in keys) {
				const multiplier = keys[key]
				root.setMockValue("/Ac/%1/L%2/Power".arg(key).arg(randomIndex + 1), power * multiplier)
				root.setMockValue("/Ac/%1/L%2/Current".arg(key).arg(randomIndex + 1), current * multiplier)
			}
		}
	}

	readonly property VeQuickItem _input1MaximumAcCurrent: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Ac/AcIn1/Consumption/Current/Max"
		Component.onCompleted: setValue(50.1235)    // settings page should show this with precision=1
	}

	readonly property VeQuickItem _input2MaximumAcCurrent: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Ac/AcIn2/Consumption/Current/Max"
		Component.onCompleted: setValue(100.98483)
	}

	readonly property VeQuickItem _maximumAcCurrent: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Ac/NoAcIn/Consumption/Current/Max"
		Component.onCompleted: setValue(20.4455)
	}

	//--- veBus ---

	readonly property VeQuickItem veBusService: VeQuickItem {
		uid: Global.system.serviceUid + "/VebusService"
	}

	property Connections veBusServiceSetup: Connections {
		target: Global.inverterChargers.veBusDevices
		function onFirstObjectChanged() {
			const device = Global.inverterChargers.veBusDevices.firstObject
			if (device) {
				// Write uid like "com.victronenergy.vebus.tty0", without "mock/" prefix
				const uid = device.serviceUid.substring(BackendConnection.uidPrefix().length)
				root.veBusService.setValue(uid)
			} else {
				root.veBusService.setValue("")
			}
		}
	}

	//--- PV data ---

	function _updatePvTotals() {
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
			// Could set the values on any of PvOnGrid/PvOnGenset/PvOnOutput
			root.setMockValue("/Ac/PvOnOutput/NumberOfPhases", phaseCount)
			for (phaseIndex = 0; phaseIndex < phaseCount; ++phaseIndex) {
				root.setMockValue("/Ac/PvOnOutput/L%1/Power".arg(phaseIndex + 1), phasePowers[phaseIndex])
				root.setMockValue("/Ac/PvOnOutput/L%1/Current".arg(phaseIndex + 1), phaseCurrents[phaseIndex])
			}
			// Reset any other phase values from previous configurations.
			for (phaseIndex = phaseCount; phaseIndex < 3; ++phaseIndex) {
				root.setMockValue("/Ac/PvOnOutput/L%1/Power".arg(phaseIndex + 1), phasePowers[phaseIndex])
				root.setMockValue("/Ac/PvOnOutput/L%1/Current".arg(phaseIndex + 1), phaseCurrents[phaseIndex])
			}
		} else {
			root.setMockValue("/Ac/PvOnOutput/NumberOfPhases", undefined)
			for (phaseIndex = 0; phaseIndex < 3; ++phaseIndex) {
				root.setMockValue("/Ac/PvOnOutput/L%1/Power".arg(phaseIndex + 1), undefined)
				root.setMockValue("/Ac/PvOnOutput/L%1/Current".arg(phaseIndex + 1), undefined)
			}
		}

		let dcPower = NaN
		if (solarDevices.model.count) {
			for (let i = 0; i < solarDevices.model.count; ++i) {
				const charger = solarDevices.model.deviceAt(i)
				if (charger) {
					dcPower = Units.sumRealNumbers(dcPower, charger.power)
				}
			}
		}
		root.setMockValue("/Dc/Pv/Power", dcPower)
		root.setMockValue("/Dc/Pv/Current", dcPower * 0.01)
	}

	property Instantiator solarDevices: Instantiator {
		model: Global.solarDevices.model
		delegate: QtObject {
			readonly property real power: modelData.power
			onPowerChanged: Qt.callLater(root._updatePvTotals)
		}
		onCountChanged: Qt.callLater(root._updatePvTotals)
	}

	property Instantiator pvInverters: Instantiator {
		model: Global.pvInverters.model
		delegate: QtObject {
			readonly property real power: modelData.power
			readonly property var phases: modelData.phases
			onPowerChanged: Qt.callLater(root._updatePvTotals)
		}
		onCountChanged: Qt.callLater(root._updatePvTotals)
	}

	readonly property VeQuickItem _maximumPvPower: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Pv/Power/Max"
		Component.onCompleted: setValue(1000)
	}

	//---

	Component.onCompleted: {
		populate()
	}
}
