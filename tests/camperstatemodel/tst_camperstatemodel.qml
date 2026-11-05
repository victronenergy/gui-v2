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
		model.systemState = -1
		model.inverterChargerPower = NaN
		model.alternatorState = -1
		model.lowSocAlarm = model.alarmOk
		model.veBusLowBatteryAlarm = model.alarmOk
		model.solarPresent = false
		model.generatorPresent = false
	}

	function test_shore_data() {
		return [
			{ tag: "bulk", state: 3, power: NaN, charging: true, passThrough: false },
			{ tag: "absorption", state: 4, power: NaN, charging: true, passThrough: false },
			{ tag: "float", state: 5, power: NaN, charging: true, passThrough: false },
			{ tag: "passthru", state: 8, power: NaN, charging: false, passThrough: true },
			{ tag: "inverting", state: 9, power: NaN, charging: false, passThrough: false },
			{ tag: "system state invalid", state: -1, power: 500, charging: false, passThrough: false },
			{ tag: "power ignored without external control", state: 8, power: 500, charging: false, passThrough: true },
			{ tag: "external control, charging", state: 252, power: 500, charging: true, passThrough: false },
			{ tag: "external control, at threshold", state: 252, power: 30, charging: true, passThrough: false },
			{ tag: "external control, below threshold", state: 252, power: 29, charging: false, passThrough: true },
			{ tag: "external control, discharging", state: 252, power: -100, charging: false, passThrough: true },
			{ tag: "external control, no power", state: 252, power: NaN, charging: false, passThrough: false },
		]
	}

	function test_shore(data) {
		model.activeInputSource = model.sourceShore
		model.systemState = data.state
		model.inverterChargerPower = data.power
		compare(model.shoreCharging, data.charging)
		compare(model.passThrough, data.passThrough)
		compare(model.offGrid, false)
		compare(model.scenario, model.scenarioCharging)
	}

	function test_notOnShore_data() {
		return [
			{ tag: "generator", source: 2 },
			{ tag: "inverting", source: 240 },
			{ tag: "not available", source: 0 },
		]
	}

	function test_notOnShore(data) {
		model.activeInputSource = data.source
		model.systemState = 3
		model.inverterChargerPower = 500
		compare(model.shoreCharging, false)
		compare(model.passThrough, false)
		compare(model.offGrid, true)
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
		compare(model.scenario, data.driving ? model.scenarioDriving : model.scenarioOffGrid)
	}

	function test_scenario_data() {
		return [
			{ tag: "shore wins over driving", source: 3, state: 4, scenario: model.scenarioCharging },
			{ tag: "grid", source: 1, state: 0, scenario: model.scenarioCharging },
			{ tag: "driving wins over off-grid", source: 240, state: 4, scenario: model.scenarioDriving },
			{ tag: "engine off, inverting", source: 240, state: 0, scenario: model.scenarioOffGrid },
			{ tag: "generator", source: 2, state: 0, scenario: model.scenarioOffGrid },
			{ tag: "generator while driving", source: 2, state: 4, scenario: model.scenarioDriving },
			{ tag: "off-grid without alternator", source: 240, state: -1, scenario: model.scenarioOffGrid },
			{ tag: "nothing known", source: 0, state: -1, scenario: model.scenarioOffGrid },
		]
	}

	function test_scenario(data) {
		model.activeInputSource = data.source
		model.alternatorState = data.state
		compare(model.scenario, data.scenario)
	}

	function test_solarOnly_data() {
		return [
			{ tag: "solar, no generator", solar: true, generator: false, solarOnly: true },
			{ tag: "solar and generator", solar: true, generator: true, solarOnly: false },
			{ tag: "no solar, no generator", solar: false, generator: false, solarOnly: false },
		]
	}

	function test_solarOnly(data) {
		model.solarPresent = data.solar
		model.generatorPresent = data.generator
		compare(model.solarOnly, data.solarOnly)
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
		// The battery's low SOC alarm does not stop the inverter/charger.
		compare(model.acOutputCut, false)
	}

	function test_acOutputCut_data() {
		return [
			{ tag: "inactive", alarm: 0, cut: false },
			{ tag: "warning", alarm: 1, cut: false },
			{ tag: "alarm", alarm: 2, cut: true },
		]
	}

	function test_acOutputCut(data) {
		model.veBusLowBatteryAlarm = data.alarm
		compare(model.acOutputCut, data.cut)
	}

	function test_lowBatteryAlarm_coexistsWithOtherStates() {
		model.activeInputSource = model.sourceShore
		model.systemState = 3
		model.lowSocAlarm = 2
		compare(model.lowBatteryAlarm, true)
		compare(model.shoreCharging, true)
	}
}
