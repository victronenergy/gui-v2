/*
 * Copyright (C) 2026 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

/*
	Tests the derivation of the RV states, from the table in the "Custom Illustrations" section of
	the UI design document.
*/
TestCase {
	id: root

	name: "CamperStateModelTest"

	CamperStateModel {
		id: model
	}

	function init() {
		model.activeInputSource = model.sourceNotAvailable
		model.acInputConnected = false
		model.alternatorState = -1
		model.batteryPower = NaN
		model.lowSocAlarm = 0
	}

	function test_shore_data() {
		return [
			{ tag: "charging", power: 500, charging: true },
			{ tag: "at threshold", power: 30, charging: true },
			{ tag: "below threshold", power: 29, charging: false },
			{ tag: "idle", power: 0, charging: false },
			{ tag: "discharging", power: -100, charging: false },
			{ tag: "no battery", power: NaN, charging: false },
		]
	}

	function test_shore(data) {
		model.activeInputSource = model.sourceShore
		model.acInputConnected = true
		model.batteryPower = data.power
		compare(model.shoreCharging, data.charging)
		compare(model.passThrough, !data.charging)
		compare(model.offGrid, false)
		compare(model.scenario, model.scenarioCharging)
	}

	function test_driving_data() {
		return [
			{ tag: "off", state: 0, driving: false },
			{ tag: "fault", state: 2, driving: false },
			{ tag: "bulk", state: 3, driving: true },
			{ tag: "absorption", state: 4, driving: true },
			{ tag: "float", state: 5, driving: true },
			{ tag: "storage", state: 6, driving: true },
			{ tag: "equalize", state: 7, driving: true },
			{ tag: "above range", state: 8, driving: false },
			{ tag: "external control", state: 252, driving: true },
			{ tag: "no alternator", state: -1, driving: false },
		]
	}

	function test_driving(data) {
		model.activeInputSource = model.sourceInverting
		model.alternatorState = data.state
		compare(model.driving, data.driving)
		if (data.driving) {
			compare(model.scenario, model.scenarioDriving)
		} else {
			verify(model.scenario !== model.scenarioDriving)
		}
	}

	function test_parked_data() {
		return [
			{ tag: "engine off, inverting", state: 0, source: 240, parked: true },
			{ tag: "engine off, no source", state: 0, source: 0, parked: false },
			{ tag: "engine running, inverting", state: 3, source: 240, parked: false },
			{ tag: "no alternator, inverting", state: -1, source: 240, parked: false },
		]
	}

	function test_parked(data) {
		model.alternatorState = data.state
		model.activeInputSource = data.source
		compare(model.parked, data.parked)
	}

	function test_scenario_data() {
		return [
			{ tag: "shore wins over driving", source: 3, connected: true, state: 4, scenario: model.scenarioCharging },
			{ tag: "grid", source: 1, connected: true, state: 0, scenario: model.scenarioCharging },
			{ tag: "driving wins over off-grid", source: 240, connected: false, state: 4, scenario: model.scenarioDriving },
			{ tag: "parked wins over off-grid", source: 240, connected: false, state: 0, scenario: model.scenarioParking },
			{ tag: "generator", source: 2, connected: true, state: 0, scenario: model.scenarioParking },
			{ tag: "off-grid without alternator", source: 240, connected: false, state: -1, scenario: model.scenarioOffGrid },
			{ tag: "nothing known", source: 0, connected: false, state: -1, scenario: model.scenarioOffGrid },
		]
	}

	function test_scenario(data) {
		model.activeInputSource = data.source
		model.acInputConnected = data.connected
		model.alternatorState = data.state
		compare(model.scenario, data.scenario)
	}

	function test_offGrid() {
		compare(model.offGrid, true)
		model.acInputConnected = true
		compare(model.offGrid, false)
	}

	function test_lowBatteryAlarm_data() {
		return [
			{ tag: "inactive", alarm: 0, active: false },
			{ tag: "warning", alarm: 1, active: false },
			{ tag: "alarm", alarm: 2, active: true },
		]
	}

	function test_lowBatteryAlarm(data) {
		model.lowSocAlarm = data.alarm
		compare(model.lowBatteryAlarm, data.active)
	}

	function test_lowBatteryAlarm_coexistsWithOtherStates() {
		model.activeInputSource = model.sourceShore
		model.acInputConnected = true
		model.batteryPower = 500
		model.lowSocAlarm = 2
		compare(model.lowBatteryAlarm, true)
		compare(model.shoreCharging, true)
	}
}
