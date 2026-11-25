/*
 * Copyright (C) 2026 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtQuick
import Victron.Camper
import QtTest

/*
	Tests the derivation of the RV states, from the table in the "Custom Illustrations" section of
	the UI design document.
*/
TestCase {
	id: root

	name: "CamperStateTest"

	CamperState {
		id: model
	}

	function init() {
		model.activeInputSource = model.sourceNotAvailable
		model.acInputSources = []
		model.systemState = -1
		model.inverterChargerPower = NaN
		model.alternatorStates = []
		model.lowSocAlarm = model.alarmOk
		model.veBusLowBatteryAlarm = model.alarmOk
		model.solarDeviceCount = 0
		model.activeInputPower = NaN
		model.generatorPower = NaN
		model.solarPower = NaN
		model.alternatorPower = NaN
		model.batteryPower = NaN
		model.dcLoadsPower = NaN
		model.acLoadsPower = NaN
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

	// Grid is treated as shore, so every row is checked for both.
	function test_shore(data) {
		for (const source of [model.sourceShore, model.sourceGrid]) {
			model.activeInputSource = source
			model.systemState = data.state
			model.inverterChargerPower = data.power
			compare(model.shoreCharging, data.charging)
			compare(model.passThrough, data.passThrough)
			compare(model.scenario, model.scenarioCharging)
		}
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
		compare(model.scenario, model.scenarioOffGrid)
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
		model.alternatorStates = [data.state]
		compare(model.driving, data.driving)
		compare(model.scenario, data.driving ? model.scenarioDriving : model.scenarioOffGrid)
	}

	function test_drivingWithSeveralAlternators_data() {
		return [
			{ tag: "none", states: [], driving: false },
			{ tag: "one running", states: [0, 4], driving: true },
			{ tag: "first running", states: [252, 0], driving: true },
			{ tag: "none running", states: [0, 2], driving: false },
			{ tag: "one unknown, one running", states: [-1, 5], driving: true },
			{ tag: "all unknown", states: [-1, -1], driving: false },
		]
	}

	function test_drivingWithSeveralAlternators(data) {
		model.alternatorStates = data.states
		compare(model.driving, data.driving)
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
			{ tag: "no input available", source: 0, state: -1, scenario: model.scenarioOffGrid },
			{ tag: "source unknown", source: -1, state: -1, scenario: model.scenarioUnknown },
			{ tag: "source unknown, driving", source: -1, state: 4, scenario: model.scenarioDriving },
		]
	}

	function test_scenario(data) {
		model.activeInputSource = data.source
		model.alternatorStates = [data.state]
		compare(model.scenario, data.scenario)
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

	function test_inverterChargerOff_data() {
		return [
			{ tag: "unknown", state: -1, off: false },
			{ tag: "off", state: 0, off: true },
			{ tag: "bulk", state: 3, off: false },
			{ tag: "inverting", state: 9, off: false },
		]
	}

	function test_inverterChargerOff(data) {
		model.systemState = data.state
		compare(model.inverterChargerOff, data.off)
	}

	function test_lowBatteryAlarm_coexistsWithOtherStates() {
		model.activeInputSource = model.sourceShore
		model.systemState = 3
		model.lowSocAlarm = 2
		compare(model.lowBatteryAlarm, true)
		compare(model.shoreCharging, true)
	}

	// Unknown inputs must not read as a known state.
	function test_defaultsAreUnknown() {
		const state = Qt.createQmlObject("import Victron.Camper; CamperState {}", root)
		compare(state.activeInputSource, state.sourceUnknown)
		compare(state.systemState, state.systemStateUnknown)
		compare(state.lowSocAlarm, state.alarmUnknown)
		compare(state.veBusLowBatteryAlarm, state.alarmUnknown)
		compare(state.sourceKnown, false)
		compare(state.externalAcInput, false)
		compare(state.scenario, state.scenarioUnknown)
		compare(state.lowBatteryAlarm, false)
		compare(state.lowBatteryAlarmKnown, false)
		compare(state.acOutputCut, false)
		compare(state.acOutputCutKnown, false)
		compare(state.inverterChargerOff, false)
		state.destroy()
	}

	function test_alarmKnown_data() {
		return [
			{ tag: "unknown", alarm: -1, active: false, known: false },
			{ tag: "ok", alarm: 0, active: false, known: true },
			{ tag: "warning", alarm: 1, active: false, known: true },
			{ tag: "alarm", alarm: 2, active: true, known: true },
		]
	}

	function test_alarmKnown(data) {
		model.lowSocAlarm = data.alarm
		model.veBusLowBatteryAlarm = data.alarm
		compare(model.lowBatteryAlarm, data.active)
		compare(model.lowBatteryAlarmKnown, data.known)
		compare(model.acOutputCut, data.active)
		compare(model.acOutputCutKnown, data.known)
	}

	function test_presence_data() {
		return [
			{ tag: "nothing", solarDevices: 0, sources: [], solar: false, generator: false },
			{ tag: "one solar charger", solarDevices: 1, sources: [3, -1], solar: true, generator: false },
			{ tag: "generator on input 2", solarDevices: 0, sources: [3, 2], solar: false, generator: true },
			{ tag: "generator on input 1", solarDevices: 2, sources: [2, 1], solar: true, generator: true },
			{ tag: "inputs unknown", solarDevices: 0, sources: [-1, -1], solar: false, generator: false },
		]
	}

	function test_presence(data) {
		model.solarDeviceCount = data.solarDevices
		model.acInputSources = data.sources
		compare(model.solarPresent, data.solar)
		compare(model.generatorPresent, data.generator)
	}

	function test_activeCards_data() {
		return [
			{ tag: "unknown", power: NaN, active: false },
			{ tag: "zero", power: 0, active: false },
			{ tag: "noise", power: 29, active: false },
			{ tag: "at threshold", power: 30, active: true },
			{ tag: "negative noise", power: -29, active: false },
			{ tag: "negative", power: -30, active: true },
		]
	}

	// Every card uses the same noise rule, in either direction.
	function test_activeCards(data) {
		model.activeInputSource = model.sourceShore
		model.acInputSources = [model.sourceShore, model.sourceGenerator]
		model.activeInputPower = data.power
		model.generatorPower = data.power
		model.solarPower = data.power
		model.alternatorPower = data.power
		model.batteryPower = data.power
		model.dcLoadsPower = data.power
		model.acLoadsPower = data.power
		compare(model.gridShoreActive, data.active)
		compare(model.generatorActive, data.active)
		compare(model.solarActive, data.active)
		compare(model.alternatorActive, data.active)
		compare(model.batteryActive, data.active)
		compare(model.dcLoadsActive, data.active)
		compare(model.acLoadsActive, data.active)
	}

	function test_gridShorePower_data() {
		return [
			{ tag: "shore", source: 3, power: 1850 },
			{ tag: "grid", source: 1, power: 1850 },
			{ tag: "generator", source: 2, power: NaN },
			{ tag: "inverting", source: 240, power: NaN },
			{ tag: "unknown", source: -1, power: NaN },
		]
	}

	// The active input's power belongs to the shore card only while that input is shore or grid.
	function test_gridShorePower(data) {
		model.activeInputSource = data.source
		model.activeInputPower = 1850
		compare(model.gridShorePower, data.power)
		compare(model.gridShoreActive, !isNaN(data.power))
	}

	function test_generatorNeedsAnInput() {
		model.generatorPower = 2600
		compare(model.generatorActive, false)
		compare(model.flowGeneratorToHub, false)
		model.acInputSources = [model.sourceShore, model.sourceGenerator]
		compare(model.generatorActive, true)
		compare(model.flowGeneratorToHub, false)
		model.activeInputSource = model.sourceGenerator
		compare(model.flowGeneratorToHub, true)
	}

	function test_hubActive_data() {
		return [
			{ tag: "off", state: 0, power: 500, active: false },
			{ tag: "inverting", state: 9, power: 0, active: true },
			{ tag: "unknown, power flowing", state: -1, power: 500, active: true },
			{ tag: "unknown, no power", state: -1, power: 0, active: false },
		]
	}

	function test_hubActive(data) {
		model.systemState = data.state
		model.dcLoadsPower = data.power
		compare(model.hubActive, data.active)
	}

	function test_batteryMode_data() {
		return [
			{ tag: "unknown", power: NaN, charging: false, discharging: false },
			{ tag: "idle", power: 0, charging: false, discharging: false },
			{ tag: "charging below the noise threshold", power: 5, charging: true, discharging: false },
			{ tag: "discharging", power: -780, charging: false, discharging: true },
		]
	}

	// As gui-v2's battery_modeFromPower(): any sign counts, with no noise threshold.
	function test_batteryMode(data) {
		model.batteryPower = data.power
		compare(model.batteryCharging, data.charging)
		compare(model.batteryDischarging, data.discharging)
	}

	function test_flows_data() {
		return [
			{
				tag: "shore charging",
				source: 3, state: 3, input: 1850, battery: 560, solar: 320, dc: 210, ac: 1080,
				flows: ["GridToHub", "HubToBattery", "SolarToBattery", "BatteryToDc", "HubToAc"],
			},
			{
				tag: "pass-through",
				source: 3, state: 8, input: 1080, battery: 0, dc: 210, ac: 1080,
				flows: ["GridToHub", "BatteryToDc", "HubToAc"],
			},
			{
				tag: "shore, battery charged by solar while passing through",
				source: 3, state: 8, input: 1080, battery: 300, solar: 320, ac: 1080,
				flows: ["GridToHub", "SolarToBattery", "HubToAc"],
			},
			{
				tag: "generator charging",
				source: 2, sources: [3, 2], state: 3, generator: 2600, battery: 900, dc: 210, ac: 1400,
				flows: ["GeneratorToHub", "HubToBattery", "BatteryToDc", "HubToAc"],
			},
			{
				tag: "generator running, shore connected",
				source: 3, sources: [3, 2], state: 3, input: 1850, generator: 2600, battery: 560, dc: 210, ac: 1080,
				flows: ["GridToHub", "HubToBattery", "BatteryToDc", "HubToAc"],
			},
			{
				tag: "generator running, not connected, while inverting",
				source: 240, sources: [3, 2], state: 9, generator: 2600, battery: 300, solar: 320, ac: 890,
				flows: ["SolarToBattery", "HubToAc", "BatteryToHub"],
			},
			{
				tag: "driving",
				source: 240, state: 0, alternator: 620, battery: 480, solar: 320, dc: 210,
				flows: ["AlternatorToBattery", "SolarToBattery", "BatteryToDc"],
			},
			{
				tag: "off-grid, inverting",
				source: 240, state: 9, battery: -780, solar: 320, dc: 210, ac: 890,
				flows: ["BatteryToDc", "HubToAc", "BatteryToHub"],
			},
			{
				tag: "solar does not reach a discharging battery",
				source: 240, state: 9, battery: -100, solar: 320, ac: 890,
				flows: ["HubToAc", "BatteryToHub"],
			},
			{
				tag: "AC output cut",
				source: 240, state: 2, veBusAlarm: 2, battery: -320, dc: 320, ac: 100,
				flows: ["BatteryToDc"],
			},
			{
				tag: "noise draws nothing",
				source: 3, state: 3, input: 29, battery: 29, solar: 29, alternator: 29, dc: 29, ac: 29,
				flows: [],
			},
			{
				tag: "nothing known",
				source: -1, flows: [],
			},
		]
	}

	function test_flows(data) {
		const allFlows = ["GridToHub", "GeneratorToHub", "SolarToBattery", "AlternatorToBattery",
				"BatteryToDc", "HubToAc", "BatteryToHub", "HubToBattery"]
		model.activeInputSource = data.source
		model.acInputSources = data.sources ?? []
		model.systemState = data.state ?? -1
		model.veBusLowBatteryAlarm = data.veBusAlarm ?? 0
		model.activeInputPower = data.input ?? NaN
		model.generatorPower = data.generator ?? NaN
		model.solarPower = data.solar ?? NaN
		model.alternatorPower = data.alternator ?? NaN
		model.batteryPower = data.battery ?? NaN
		model.dcLoadsPower = data.dc ?? NaN
		model.acLoadsPower = data.ac ?? NaN
		for (const flow of allFlows) {
			compare(model["flow" + flow], data.flows.indexOf(flow) >= 0, flow)
		}
	}
}
