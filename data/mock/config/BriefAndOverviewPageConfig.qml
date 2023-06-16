/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property var configs: [
		{
			name: "ESS - AC & DC coupled.  PV Inverter on AC Bus + AC output",
			acInputs: { type: VenusOS.AcInputs_InputType_Grid, phaseCount: 3, connected: true },
			solar: { chargers: [ { acPower: 123, dcPower: 456 } ] },
			system: { state: VenusOS.System_State_Inverting, ac: {}, dc: {} },
			battery: { stateOfCharge: 64, current: 1 },
		},
		{
			name: "ESS - AC & DC coupled. PV Inverter on AC Out",
			acInputs: { type: VenusOS.AcInputs_InputType_Grid, phaseCount: 3, connected: true },
			solar: { chargers: [ { acPower: 123, dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 73, current: -1 },
		},
		// TODO "ESS - AC & DC coupled. PV Inverter on AC Out (Amps version)",
		{
			name: "Phase self consumption",
			acInputs: { type: VenusOS.AcInputs_InputType_Generator, phaseCount: 3, connected: true },
			solar: { chargers: [ { acPower: 123, dcPower: 456 } ] },
			system: { state: VenusOS.System_State_PassThrough, ac: {} },
			battery: { stateOfCharge: 29, current: 1 },
		},
		{
			name: "Off grid",
			acInputs: { type: VenusOS.AcInputs_InputType_Generator, phaseCount: 3, connected: false },
			solar: { chargers: [ { acPower: 123, dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 95, current: 1 },
		},
		{
			name: "ESS - AC coupled on AC Output",
			acInputs: { type: VenusOS.AcInputs_InputType_Grid, phaseCount: 1, connected: true },
			solar: { chargers: [ { acPower: 123 } ] },
			system: { state: VenusOS.System_State_FloatCharging, ac: {} },
			battery: { stateOfCharge: 100, current: 0 },
		},
		{
			name: "Pure Energy Storage - no PV",
			acInputs: { type: VenusOS.AcInputs_InputType_Grid, phaseCount: 1, connected: true },
			// TODO state should be 'Scheduled charging', but not in dbus API?
			system: { state: VenusOS.System_State_FloatCharging, ac: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Combo one (amps): Shore / DC Generator / Left & Right Alternator / Solar",
			acInputs: { type: VenusOS.AcInputs_InputType_Shore, phaseCount: 3, connected: true },
			dcInputs: { types: [ VenusOS.DcInputs_InputType_DcGenerator, VenusOS.DcInputs_InputType_Alternator ] },
			solar: { chargers: [ { dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Single-phase Shore",
			acInputs: { type: VenusOS.AcInputs_InputType_Shore, phaseCount: 1, connected: true },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Single phase + solar",
			acInputs: { type: VenusOS.AcInputs_InputType_Shore, phaseCount: 1, connected: true },
			solar: { chargers: [ { dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Small RV with alternator or small boat",
			acInputs: { type: VenusOS.AcInputs_InputType_Shore, phaseCount: 1, connected: true },
			dcInputs: { types: [ VenusOS.DcInputs_InputType_Alternator ] },
			solar: { chargers: [ { dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Catamaran with wind: Shore / Solar / Left alternator / Right alternator / Wind",
			acInputs: { type: VenusOS.AcInputs_InputType_Shore, phaseCount: 1, connected: true },
			dcInputs: { types: [ VenusOS.DcInputs_InputType_Alternator, VenusOS.DcInputs_InputType_Wind ] },
			solar: { chargers: [ { dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Boat with DC generator",
			acInputs: { type: VenusOS.AcInputs_InputType_Shore, phaseCount: 1, connected: true },
			dcInputs: { types: [ VenusOS.DcInputs_InputType_DcGenerator, VenusOS.DcInputs_InputType_Alternator, VenusOS.DcInputs_InputType_Wind ] },
			solar: { chargers: [ { dcPower: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Multiple solar chargers",
			solar: { chargers: [ { acPower: 123 }, { dcPower: 456 }, { acPower: 234 } ] },
		},
		{
			name: "AC Loads + 1 EVCS + DC Loads",
			acInputs: { type: VenusOS.AcInputs_InputType_Grid, phaseCount: 1, connected: true },
			system: { state: VenusOS.System_State_FloatCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 100, current: 0 },
			evcs: { chargers: [ { status: VenusOS.Evcs_Status_Charging, mode: VenusOS.Evcs_Mode_Auto } ] }
		},
		{
			name: "AC Loads + 3 EVCS",
			acInputs: { type: VenusOS.AcInputs_InputType_Grid, phaseCount: 1, connected: true },
			system: { state: VenusOS.System_State_FloatCharging, ac: {} },
			battery: { stateOfCharge: 100, current: 0 },
			evcs: { chargers: [ { status: VenusOS.Evcs_Status_Charging }, { status: VenusOS.Evcs_Status_Charging }, { status: VenusOS.Evcs_Status_Disconnected } ] },
		}

	]

	function configCount() {
		return configs.length
	}

	function loadConfig(configIndex) {
		const config = configs[configIndex]
		Global.mockDataSimulator.setAcInputsRequested(config.acInputs)
		Global.mockDataSimulator.setDcInputsRequested(config.dcInputs)
		Global.mockDataSimulator.setSolarChargersRequested(config.solar)
		Global.mockDataSimulator.setSystemRequested(config.system)
		Global.mockDataSimulator.setBatteryRequested(config.battery)
		Global.mockDataSimulator.setEvChargersRequested(config.evcs)
		return config.name
	}
}
