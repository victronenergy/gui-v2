/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property var emptyAcInput: ({
		source: VenusOS.AcInputs_InputSource_NotAvailable,
		serviceType: "",
		serviceName: "",
		connected: 0,
		phaseCount: 0,
	})

	readonly property var configs: [
		{
			name: "ESS - AC & DC coupled. 1-phase PV Inverter on AC Bus + AC output",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			solar: { inverters: [ { phaseCount: 1 } ] },
			system: { state: VenusOS.System_State_Inverting, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc"] } },
			battery: { stateOfCharge: 64, current: 1 },
		},
		{
			name: "ESS - AC & DC coupled. 3-phase PV Inverter on AC Out",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			solar: { inverters: [ { phaseCount: 3 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc","dcload"] } },
			battery: { stateOfCharge: 73, current: -1 },
		},
		// TODO "ESS - AC & DC coupled. PV Inverter on AC Out (Amps version)",
		{
			name: "Phase self consumption",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "vebus", serviceName: "com.victronenergy.genset.ttyUSB0", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			generators: { running: true },
			solar: { chargers: [ { power: 300 } ], inverters: [ { phaseCount: 3 } ] },
			system: { state: VenusOS.System_State_PassThrough, ac: { phaseCount: 3 } },
			battery: { stateOfCharge: 29, current: 1 },
		},
		{
			name: "Off grid",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "vebus", serviceName: "com.victronenergy.genset.ttyUSB0", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			generators: { running: false },
			solar: { chargers: [ { power: 300 } ], inverters: [ { phaseCount: 3 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 1 }, dc: { serviceTypes: ["dcload", "dcdc"] } },
			battery: { stateOfCharge: 95, current: 1 },
		},
		{
			name: "ESS - AC coupled on AC Output",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			solar: { inverters: [ { phaseCount: 3 } ] },
			system: { state: VenusOS.System_State_FloatCharging, ac: { phaseCount: 1 } },
			battery: { stateOfCharge: 100, current: 0 },
		},
		{
			name: "Pure Energy Storage - no PV",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			// TODO state should be 'Scheduled charging', but not in dbus API?
			system: { state: VenusOS.System_State_FloatCharging, ac: { phaseCount: 1 } },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Combo one (amps): Shore / DC Generator / Left & Right Alternator / Solar",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			dcInputs: {  types: [ { serviceType: "dcsource", monitorMode: -1 }, { serviceType: "alternator", monitorMode: -1 } ] },
			solar: { chargers: [ { power: 300 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc"] } },
		},
		{
			name: "Single-phase Shore",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 1 }, dc: { serviceTypes: ["dcdc"] } },
		},
		{
			name: "Single phase + solar",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 1 }, dc: { serviceTypes: ["dcsystem"] } },
		},
		{
			name: "Small RV with alternator or small boat",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			dcInputs: {  types: [ { serviceType: "alternator", monitorMode: -1 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcload"] } },
		},
		{
			name: "Catamaran with wind: Shore / Solar / Left alternator / Right alternator / Wind",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			dcInputs: {  types: [ { serviceType: "alternator", monitorMode: -1 }, { serviceType: "dcsource", monitorMode: -8 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc","dcload"] } },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Boat with DC generator",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			dcInputs: {  types: [ { serviceType: "dcsource", monitorMode: -1 }, { serviceType: "alternator", monitorMode: -1 }, { serviceType: "dcsource", monitorMode: -8 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc","dcload"] } },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Multiple solar chargers",
			solar: { chargers: [ { phaseCount: 1 }, { power: 456 }, { power: 234 } ] },
		},
		{
			name: "AC Loads + 1 EVCS + DC Loads, 1-phase AC input",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			system: { state: VenusOS.System_State_FloatCharging, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc","dcload"] } },
			battery: { stateOfCharge: 100, current: 0 },
			evcs: { chargers: [ { status: VenusOS.Evcs_Status_Charging, mode: VenusOS.Evcs_Mode_Auto } ] }
		},
		{
			name: "AC Loads + 3 EVCS, 3-phase AC input",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			system: { state: VenusOS.System_State_FloatCharging, ac: { phaseCount: 3 } },
			battery: { stateOfCharge: 100, current: 0 },
			evcs: { chargers: [ { status: VenusOS.Evcs_Status_Charging }, { status: VenusOS.Evcs_Status_Charging }, { status: VenusOS.Evcs_Status_Disconnected } ] },
		},
		{
			name: "Single 3-phase PV inverter, no AC/DC inputs",
			acInputs: [emptyAcInput, emptyAcInput],
			system: { state: VenusOS.System_State_FloatCharging, ac: { phaseCount: 3 } },
			solar: { inverters: [ { phaseCount: 3 } ] },
		},
		{
			name: "Multiple 1-phase PV inverters, no AC/DC inputs",
			acInputs: [emptyAcInput, emptyAcInput],
			solar: { inverters: [ { phaseCount: 1 }, { phaseCount: 1 }, { phaseCount: 1 } ] },
		},
		{
			name: "Multiple alternators (including Orion XS), no AC/DC inputs",
			acInputs: [emptyAcInput, emptyAcInput],
			dcInputs: { types: [ { serviceType: "alternator", productId: ProductInfo.ProductId_OrionXs_Min }, { serviceType: "alternator" } ] },
		},
		{
			name: "Shore and Generator, Shore active",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 },
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", serviceName: "com.victronenergy.genset.ttyUSB0", phaseCount: 3 },
			],
		},
		{
			name: "Shore and Generator, Generator active",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3 },
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", serviceName: "com.victronenergy.genset.ttyUSB0", phaseCount: 3, connected: 1 },
			],
		},
		{
			name: "Shore + Generator + Solar, Shore active but genset also operational",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 },
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", serviceName: "com.victronenergy.genset.ttyUSB0", phaseCount: 3 },
			],
			solar: { chargers: [ { phaseCount: 1 }, { power: 456 }, { power: 234 } ] },
		},
		{
			name: "Shore + Generator + Solar, Generator active but genset also operational",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3 },
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", serviceName: "com.victronenergy.genset.ttyUSB0", phaseCount: 3, connected: 1 },
			],
			solar: { chargers: [ { phaseCount: 1 }, { power: 456 }, { power: 234 } ] },
		},
		{
			name: "Shore + Generator with 3-phase, with 5 left-hand widgets in total",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 },
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", serviceName: "com.victronenergy.genset.ttyUSB0", phaseCount: 3, connected: 0 },
			],
			dcInputs: {  types: [ { serviceType: "alternator", monitorMode: -1 }, { serviceType: "dcsource", monitorMode: -8 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc","dcload"] } },
			battery: { stateOfCharge: 43, current: 1 },
		},
		{
			name: "Grid connected",
			acInputs: [ { source: VenusOS.AcInputs_InputSource_Grid, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 }, emptyAcInput, ],
		},
		{
			name: "Grid disconnected",
			acInputs: [ { source: VenusOS.AcInputs_InputSource_Grid, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 0 }, emptyAcInput, ],
		},
		{
			name: "AC Loads + Essential Loads; EVCS connected to AC Loads only",
			system: { showInputLoads: true, hasAcOutSystem: 1, ac: { phaseCount: 1 }, dc: { serviceTypes: ["dcload"] } },
			evcs: {
				chargers: [
					{ status: VenusOS.Evcs_Status_Charging, position: VenusOS.AcPosition_AcInput },
				]
			}
		},
		{
			name: "AC Loads + Essential Loads; EVCS connected to Essential Loads only",
			system: { showInputLoads: true, hasAcOutSystem: 1, ac: {}, dc: { serviceTypes: ["dcload"] } },
			evcs: {
				chargers: [
					{ status: VenusOS.Evcs_Status_Charging, position: VenusOS.AcPosition_AcOutput },
				]
			}
		},
		{
			name: "AC Loads + Essential Loads; EVCS connected to AC Loads + Essential Loads",
			system: { showInputLoads: true, hasAcOutSystem: 1, ac: {}, dc: { serviceTypes: ["dcload"] } },
			evcs: {
				chargers: [
					{ status: VenusOS.Evcs_Status_Charging, position: VenusOS.AcPosition_AcInput },
					{ status: VenusOS.Evcs_Status_Charging, position: VenusOS.AcPosition_AcOutput },
				]
			}
		},
		{
			name: "AC Loads only because AC-Out disabled; EVCS connected to AC Loads only",
			system: { showInputLoads: true, hasAcOutSystem: 0, ac: {}, dc: { serviceTypes: ["dcload"] } },
			evcs: {
				chargers: [
					{ status: VenusOS.Evcs_Status_Charging, position: VenusOS.AcPosition_AcInput },
					{ status: VenusOS.Evcs_Status_Charging, position: VenusOS.AcPosition_AcOutput },
				]
			}
		},
		{
			name: "AC Loads only because showInputLoads=false; EVCS connected to AC Loads only",
			system: { showInputLoads: false, hasAcOutSystem: 1, ac: {}, dc: { serviceTypes: ["dcload"] } },
			evcs: {
				chargers: [
					{ status: VenusOS.Evcs_Status_Charging, position: VenusOS.AcPosition_AcInput },
					{ status: VenusOS.Evcs_Status_Charging, position: VenusOS.AcPosition_AcOutput },
				]
			}
		},
		{
			// Two inputs on the Multi/Quattro. The quattro can only measure the one that is active.
			// Both inputs get data from com.victronenergy.vebus.<suffix>/Ac/ActiveIn/Lx/{P,V,I,F}
			// but only the one that has Connected=1 should show information on the UI.
			name: "Generator + Shore on Multi/Quattro (Generator connected)",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 },
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 0 },
			]
		},
		{
			// One input (generator) on the Multi/Quattro, other input (grid) on dedicated energy meter.
			// Generator data from com.victronenergy.vebus.<suffix>/Ac/ActiveIn/Lx/{P,V,I,F} (when active).
			// Grid data from com.victronenergy.grid.<suffix>/Ac/Lx/{Power,Voltage,Current}.
			name: "Generator on Multi/Quattro + Grid on energy meter (Grid connected)",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 0 },
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "grid", serviceName: "com.victronenergy.grid.ttyUSB0", phaseCount: 3, connected: 1 },
			]
		},
		{
			// Same as previous case, but Multi/Quattro input is connected.
			// Generator is connected, but the Grid is the highlighted input.
			name: "Generator on Multi/Quattro + Grid on energy meter (Generator connected but both operational)",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 },
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "grid", serviceName: "com.victronenergy.grid.ttyUSB0", phaseCount: 3, connected: 0 },
			]
		},
		{
			// Both inputs (generator and grid) are on dedicated energy meters.
			// Generator is connected, but the Grid is the highlighted input.
			// Generator data from com.victronenergy.genset.<suffix>/Ac/ActiveIn/Lx/{Power,Voltage,Current}.
			// Grid data from com.victronenergy.grid.<suffix>/Ac/Lx/{Power,Voltage,Current}.
			name: "Generator + Grid on energy meters (Grid connected but both operational)",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", serviceName: "com.victronenergy.genset.ttyUSB0", phaseCount: 3, connected: 1 },
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "grid", serviceName: "com.victronenergy.grid.ttyUSB0", phaseCount: 3, connected: 0},
			]
		},
		{
			// Multi-RS, which only one AC input.
			// Input data comes from com.victronenergy.acsystem.socketcan_can0_vi0_uc162268/Ac/In/1/Lx/{P,V,I,F}.
			name: "Generator on Multi-RS (connected)",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "acsystem", serviceName: "com.victronenergy.acsystem.ttyUSB0", phaseCount: 3, connected: 1 },
				emptyAcInput,
			]
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
