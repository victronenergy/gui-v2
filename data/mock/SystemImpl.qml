/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	function populate() {
		Global.system.state = VenusOS.System_State_AbsorptionCharging
		Global.system.ac.consumption.setPhaseCount(_phaseCount)
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetSystemRequested(config) {
			Global.system.state = VenusOS.System_State_Off

			if (config) {
				Global.system.state = config.state

				if (config.ac) {
					randomizeAcValues.running = true
				} else {
					randomizeAcValues.running = false
					Global.system.ac.consumption.setPhaseCount(0)
				}

				if (config.dc) {
					randomizeDcValues.running = true
				} else {
					randomizeDcValues.running = false
					Global.system.dc.reset()
				}
			}
		}
	}

	//--- AC data ---

	readonly property int _phaseCount: 1 + Math.floor(Math.random() * 3)

	property Timer randomizeAcValues: Timer {
		running: Global.mockDataSimulator.timersActive
		interval: 2000
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			// Use some wild fluctuations that can be seen in the Brief side panel graph
			const randomIndex = Math.floor(Math.random() * root._phaseCount)
			const power = Math.floor(Math.random() * 800)
			Global.system.ac.consumption.setPhaseData(randomIndex, { power: power, current: power * 0.01})
		}
	}

	//--- DC data ---

	property Timer randomizeDcValues: Timer {
		running: Global.mockDataSimulator.timersActive
		interval: 1000
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			Global.system.dc.power = 500 + Math.floor(Math.random() * 100)
			Global.system.dc.voltage = 20 + Math.floor(Math.random() * 10)
		}
	}

	//--- veBus ---

	readonly property VeQuickItem veBusService: VeQuickItem {
		uid: Global.system.serviceUid + "/VebusService"
	}
	readonly property VeQuickItem veBusPower: VeQuickItem {
		uid: veBusService.value ? "%1/%2/Dc/0/Power".arg(BackendConnection.uidPrefix()).arg(veBusService.value) : ""
	}

	property Connections veBusServiceSetup: Connections {
		target: Global.veBusDevices.model
		function onFirstObjectChanged() {
			if (Global.veBusDevices.model.firstObject) {
				// Write uid like "com.victronenergy.vebus.tty0", without "mock/" prefix
				const uid = Global.veBusDevices.model.firstObject.serviceUid.substring(BackendConnection.uidPrefix().length)
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
		if (pvInverters.count) {
			let acPower = 0
			for (i = 0; i < pvInverters.count; ++i) {
				const inverter = pvInverters.objectAt(i)
				if (inverter) {
					acPower += inverter.power
				}
			}
			Global.system.solar.acPower = acPower
		}
		if (solarChargers.count) {
			let dcPower = 0
			for (i = 0; i < solarChargers.count; ++i) {
				const charger = solarChargers.objectAt(i)
				if (charger) {
					dcPower += charger.power
				}
			}
			Global.system.solar.dcPower = dcPower
		}
		Global.system.solar.current = NaN
	}

	property Instantiator solarChargers: Instantiator {
		model: Global.solarChargers.model
		delegate: QtObject {
			readonly property real power: modelData.power
			onPowerChanged: root._updatePvTotals()
		}
		onCountChanged: {
			if (count === 0) {
				Global.system.solar.dcPower = NaN
			}
		}
	}

	property Instantiator pvInverters: Instantiator {
		model: Global.pvInverters.model
		delegate: QtObject {
			readonly property real power: modelData.power
			onPowerChanged: root._updatePvTotals()
		}
		onCountChanged: {
			if (count === 0) {
				Global.system.solar.acPower = NaN
			}
		}
	}

	//---

	Component.onCompleted: {
		populate()
	}
}
