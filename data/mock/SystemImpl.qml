/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		Global.system.state = VenusOS.System_State_AbsorptionCharging
		Global.system.ac.consumption.setPhaseCount(3)
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetSystemRequested(config) {
			Global.system.state = VenusOS.System_State_Off

			if (config) {
				Global.system.state = config.state

				if (config.ac) {
					randomizeAcValues.restart()  // immediately provide valid values for the new configuration
					Global.system.ac.consumption.setPhaseCount(config.ac.phaseCount || 3)
				} else {
					randomizeAcValues.running = false
					Global.system.ac.consumption.setPhaseCount(0)
				}

				if (config.dc) {
					randomizeDcValues.restart()  // immediately provide valid values for the new configuration
				} else {
					randomizeDcValues.running = false
					Global.system.dc.reset()
				}
			}
		}
	}

	//--- AC data ---

	property Timer randomizeAcValues: Timer {
		running: Global.mockDataSimulator.timersActive && _maximumAcCurrent.isValid
		interval: 2000
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			// Use some wild fluctuations that can be seen in the Brief side panel graph
			const randomIndex = Math.floor(Math.random() * Global.system.ac.consumption.phases.count)
			const currentLimit = Global.acInputs.activeInputInfo === Global.acInputs.input1Info ? _input1MaximumAcCurrent.value
					: Global.acInputs.activeInputInfo === Global.acInputs.input2Info ? _input2MaximumAcCurrent.value
					: _maximumAcCurrent.value
			const current = Math.random() * currentLimit
			const power = current * 10
			Global.system.ac.consumption.setPhaseData(randomIndex, { power: power, current: current})
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

	//--- DC data ---

	property Timer randomizeDcValues: Timer {
		running: Global.mockDataSimulator.timersActive
		interval: 1000
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			Global.system.dc.power = Math.random() * 600
			Global.system.dc.voltage = 20 + Math.floor(Math.random() * 10)
		}
	}

	readonly property VeQuickItem _maximumDcPower: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Dc/System/Power/Max"
		Component.onCompleted: setValue(600)
	}

	//--- veBus ---

	readonly property VeQuickItem veBusService: VeQuickItem {
		uid: Global.system.serviceUid + "/VebusService"
	}
	readonly property VeQuickItem veBusPower: VeQuickItem {
		uid: veBusService.value ? "%1/%2/Dc/0/Power".arg(BackendConnection.uidPrefix()).arg(veBusService.value) : ""
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

	property Timer randomizeVeBusValues: Timer {
		running: Global.mockDataSimulator.timersActive
		interval: 1000
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			root.veBusPower.setValue(500 + Math.floor(Math.random() * 100))
		}
	}

	//--- PV data ---

	function _updatePvTotals() {
		let i
		let phaseIndex
		if (pvInverters.count) {
			let phaseCount = 0
			let phasePowers = []
			let phaseCurrents = []
			for (i = 0; i < pvInverters.count; ++i) {
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
			Global.mockDataSimulator.setMockValue("com.victronenergy.system/Ac/PvOnOutput/NumberOfPhases", phaseCount)
			for (phaseIndex = 0; phaseIndex < phaseCount; ++phaseIndex) {
				Global.mockDataSimulator.setMockValue("com.victronenergy.system/Ac/PvOnOutput/L%1/Power".arg(phaseIndex + 1), phasePowers[phaseIndex])
				Global.mockDataSimulator.setMockValue("com.victronenergy.system/Ac/PvOnOutput/L%1/Current".arg(phaseIndex + 1), phaseCurrents[phaseIndex])
			}
			// Reset any other phase values from previous configurations.
			for (phaseIndex = phaseCount; phaseIndex < 3; ++phaseIndex) {
				Global.mockDataSimulator.setMockValue("com.victronenergy.system/Ac/PvOnOutput/L%1/Power".arg(phaseIndex + 1), phasePowers[phaseIndex])
				Global.mockDataSimulator.setMockValue("com.victronenergy.system/Ac/PvOnOutput/L%1/Current".arg(phaseIndex + 1), phaseCurrents[phaseIndex])
			}
		} else {
			Global.mockDataSimulator.setMockValue("com.victronenergy.system/Ac/PvOnOutput/NumberOfPhases", undefined)
			for (phaseIndex = 0; phaseIndex < 3; ++phaseIndex) {
				Global.mockDataSimulator.setMockValue("com.victronenergy.system/Ac/PvOnOutput/L%1/Power".arg(phaseIndex + 1), undefined)
				Global.mockDataSimulator.setMockValue("com.victronenergy.system/Ac/PvOnOutput/L%1/Current".arg(phaseIndex + 1), undefined)
			}
		}

		let dcPower = NaN
		if (solarChargers.model.count) {
			for (i = 0; i < solarChargers.model.count; ++i) {
				const charger = solarChargers.model.deviceAt(i)
				if (charger) {
					dcPower = Units.sumRealNumbers(dcPower, charger.power)
				}
			}
		}
		Global.mockDataSimulator.setMockValue("com.victronenergy.system/Dc/Pv/Power", dcPower)
		Global.mockDataSimulator.setMockValue("com.victronenergy.system/Dc/Pv/Current", dcPower * 0.01)
	}

	property Instantiator solarChargers: Instantiator {
		model: Global.solarChargers.model
		delegate: QtObject {
			readonly property real power: modelData.power
			readonly property var phases: modelData.phases
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
