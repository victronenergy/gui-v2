/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib

QtObject {
	id: root

	readonly property var configs: [
		{
			name: "ESS - AC & DC coupled.  PV Inverter on AC Bus + AC output",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Grid ] },
			solar: {},
			system: { state: VenusOS.System_State_Inverting, ac: {}, dc: {} },
			battery: { stateOfCharge: 64, current: 1 },
		},
		{
			name: "ESS - AC & DC coupled. PV Inverter on AC Out",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Grid ] },
			solar: {},
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 73, current: -1 },
		},
		// TODO "ESS - AC & DC coupled. PV Inverter on AC Out (Amps version)",
		{
			name: "Phase self consumption",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Generator ] },
			solar: {},
			system: { state: VenusOS.System_State_PassThrough, ac: {} },
			battery: { stateOfCharge: 29, current: 1 },
		},
		{
			name: "Off grid",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Generator ] },  // TODO 'stopped' state
			solar: {},
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 95, current: 1 },
		},
		{
			name: "ESS - AC coupled on AC Output",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Grid ] },  // TODO what does up arrow icon in Grid indicate?
			solar: {},
			system: { state: VenusOS.System_State_FloatCharging, ac: {} },
			battery: { stateOfCharge: 100, current: 0 },
		},
		{
			name: "Pure Energy Storage - no PV",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Grid ] },
			// TODO state should be 'Scheduled charging', but not in dbus API?
			system: { state: VenusOS.System_State_FloatCharging, ac: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Combo (amps): Shore / DC Generator / Left & Right Alternator / Solar",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Shore ], phases: 3 },
			dcInputs: { types: [ VenusOS.DcInputs_InputType_DcGenerator, VenusOS.DcInputs_InputType_Alternator ] },
			solar: {},
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Single-phase Shore",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Shore ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Single phase + solar",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Shore ] },
			solar: {},
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Small RV with alternator or small boat",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Shore ] },
			dcInputs: { types: [ VenusOS.DcInputs_InputType_Alternator ] },
			solar: {},
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Catamaran with wind: Shore / Solar / Left alternator / Right alternator / Wind",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Shore ] },
			dcInputs: { types: [ VenusOS.DcInputs_InputType_Alternator, VenusOS.DcInputs_InputType_Wind ] },
			solar: {},
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Boat with DC generator",
			acInputs: { types: [ VenusOS.AcInputs_InputType_Shore ] },
			dcInputs: { types: [ VenusOS.DcInputs_InputType_DcGenerator, VenusOS.DcInputs_InputType_Alternator, VenusOS.DcInputs_InputType_Wind ] },
			solar: {},
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
	]

	function loadConfig(config) {
		let i = 0
		acInputs.model.clear()
		if (config.acInputs) {
			for (i = 0; i < config.acInputs.types.length; ++i) {
				acInputs.addInput(config.acInputs.types[i], config.acInputs.phases || 1)
			}
		}
		dcInputs.model.clear()
		if (config.dcInputs) {
			for (i = 0; i < config.dcInputs.types.length; ++i) {
				dcInputs.addInput(config.dcInputs.types[i])
			}
		}
		solarChargers.clear()
		if (config.solar) {
			solarChargers.populate()
		}
		if (config.system) {
			system.state = config.system.state
			system.ac.demoTimer.running = config.system.ac !== undefined
			system.dc.demoTimer.running = config.system.dc !== undefined
		}
		if (config.battery) {
			battery.chargeAnimation.running = false
			battery.stateOfCharge = config.battery.stateOfCharge
			battery.current = config.battery.current
		}
	}

	function reset() {
		// Populate all models with random data
		acInputs.populate()
		dcInputs.populate()
		solarChargers.populate()
		system.ac.demoTimer.running = true
		system.dc.demoTimer.running = true
		battery.chargeAnimation.running = true
		demoTitle.text = ""
	}

	Component.onCompleted: reset()
}
