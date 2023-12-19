/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property var configs: [
		{
			name: "ESS - AC & DC coupled.  PV Inverter on AC Bus + AC output",
			acInputs: { source: VenusOS.AcInputs_InputSource_Grid, phaseCount: 3 },
			solar: { chargers: [ { power: 300 } ], inverters: [ { power: 1000 } ] },
			system: { state: VenusOS.System_State_Inverting, ac: {}, dc: {} },
			battery: { stateOfCharge: 64, current: 1 },
		},
		{
			name: "ESS - AC & DC coupled. PV Inverter on AC Out",
			acInputs: { source: VenusOS.AcInputs_InputSource_Grid, phaseCount: 3 },
			solar: { chargers: [ { power: 300 } ], inverters: [ { power: 1000 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 73, current: -1 },
		},
		// TODO "ESS - AC & DC coupled. PV Inverter on AC Out (Amps version)",
		{
			name: "Phase self consumption",
			acInputs: { source: VenusOS.AcInputs_InputSource_Generator, phaseCount: 3 },
			generators: { running: true },
			solar: { chargers: [ { power: 300 } ], inverters: [ { power: 1000 } ] },
			system: { state: VenusOS.System_State_PassThrough, ac: {} },
			battery: { stateOfCharge: 29, current: 1 },
		},
		{
			name: "Off grid",
			acInputs: { source: VenusOS.AcInputs_InputSource_Generator, phaseCount: 3 },
			generators: { running: false },
			solar: { chargers: [ { power: 300 } ], inverters: [ { power: 1000 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 95, current: 1 },
		},
		{
			name: "ESS - AC coupled on AC Output",
			acInputs: { source: VenusOS.AcInputs_InputSource_Grid, phaseCount: 1 },
			solar: { inverters: [ { power: 1000 } ] },
			system: { state: VenusOS.System_State_FloatCharging, ac: {} },
			battery: { stateOfCharge: 100, current: 0 },
		},
		{
			name: "Pure Energy Storage - no PV",
			acInputs: { source: VenusOS.AcInputs_InputSource_Grid, phaseCount: 1 },
			// TODO state should be 'Scheduled charging', but not in dbus API?
			system: { state: VenusOS.System_State_FloatCharging, ac: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Combo one (amps): Shore / DC Generator / Left & Right Alternator / Solar",
			acInputs: { source: VenusOS.AcInputs_InputSource_Shore, phaseCount: 3 },
			dcInputs: {  types: [ { serviceType: "dcsource", monitorMode: -1 }, { serviceType: "alternator", monitorMode: -1 } ] },
			solar: { chargers: [ { power: 300 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Single-phase Shore",
			acInputs: { source: VenusOS.AcInputs_InputSource_Shore, phaseCount: 1 },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Single phase + solar",
			acInputs: { source: VenusOS.AcInputs_InputSource_Shore, phaseCount: 1 },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Small RV with alternator or small boat",
			acInputs: { source: VenusOS.AcInputs_InputSource_Shore, phaseCount: 1 },
			dcInputs: {  types: [ { serviceType: "alternator", monitorMode: -1 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
		},
		{
			name: "Catamaran with wind: Shore / Solar / Left alternator / Right alternator / Wind",
			acInputs: { source: VenusOS.AcInputs_InputSource_Shore, phaseCount: 1 },
			dcInputs: {  types: [ { serviceType: "alternator", monitorMode: -1 }, { serviceType: "dcsource", monitorMode: -8 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Boat with DC generator",
			acInputs: { source: VenusOS.AcInputs_InputSource_Shore, phaseCount: 1 },
			dcInputs: {  types: [ { serviceType: "dcsource", monitorMode: -1 }, { serviceType: "alternator", monitorMode: -1 }, { serviceType: "dcsource", monitorMode: -8 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Multiple solar chargers",
			solar: { chargers: [ { power: 123 }, { power: 456 }, { power: 234 } ] },
		},
		{
			name: "AC Loads + 1 EVCS + DC Loads",
			acInputs: { source: VenusOS.AcInputs_InputSource_Grid, phaseCount: 1 },
			system: { state: VenusOS.System_State_FloatCharging, ac: {}, dc: {} },
			battery: { stateOfCharge: 100, current: 0 },
			evcs: { chargers: [ { status: VenusOS.Evcs_Status_Charging, mode: VenusOS.Evcs_Mode_Auto } ] }
		},
		{
			name: "AC Loads + 3 EVCS",
			acInputs: { source: VenusOS.AcInputs_InputSource_Grid, phaseCount: 1 },
			system: { state: VenusOS.System_State_FloatCharging, ac: {} },
			battery: { stateOfCharge: 100, current: 0 },
			evcs: { chargers: [ { status: VenusOS.Evcs_Status_Charging }, { status: VenusOS.Evcs_Status_Charging }, { status: VenusOS.Evcs_Status_Disconnected } ] },
		},
		{
			name: "Single PV inverter",
			solar: { inverters: [ { power: 123 } ] },
		},
		{
			name: "Multiple PV inverters",
			solar: { inverters: [ { power: 123 }, { power: 456 }, { power: 234 } ] },
		},
	]

	function configCount() {
		return configs.length
	}

	function loadConfig(configIndex) {
		const config = configs[configIndex]
		Global.mockDataSimulator.setAcInputsRequested(config.acInputs)
		Global.mockDataSimulator.setDcInputsRequested(config.dcInputs)
		Global.mockDataSimulator.setGeneratorsRequested(config.generators)
		Global.mockDataSimulator.setSolarRequested(config.solar)
		Global.mockDataSimulator.setSystemRequested(config.system)
		Global.mockDataSimulator.setBatteryRequested(config.battery)
		Global.mockDataSimulator.setEvChargersRequested(config.evcs)
		return config.name
	}
}
