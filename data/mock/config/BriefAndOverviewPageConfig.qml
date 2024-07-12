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
			system: { state: VenusOS.System_State_Inverting, ac: { phaseCount: 3 }, dc: {} },
			battery: { stateOfCharge: 64, current: 1 },
		},
		{
			name: "ESS - AC & DC coupled. 3-phase PV Inverter on AC Out",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			solar: { inverters: [ { phaseCount: 3 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 3 }, dc: {} },
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
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 1 }, dc: {} },
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
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 3 }, dc: {} },
		},
		{
			name: "Single-phase Shore",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 1 }, dc: {} },
		},
		{
			name: "Single phase + solar",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 1 }, dc: {} },
		},
		{
			name: "Small RV with alternator or small boat",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			dcInputs: {  types: [ { serviceType: "alternator", monitorMode: -1 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 3 }, dc: {} },
		},
		{
			name: "Catamaran with wind: Shore / Solar / Left alternator / Right alternator / Wind",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			dcInputs: {  types: [ { serviceType: "alternator", monitorMode: -1 }, { serviceType: "dcsource", monitorMode: -8 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 3 }, dc: {} },
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
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 3 }, dc: {} },
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
			acInputs: [ { source: VenusOS.AcInputs_InputSource_Grid, serviceType: "vebus", phaseCount: 1, connected: 1 }, emptyAcInput ],
			system: { state: VenusOS.System_State_FloatCharging, ac: { phaseCount: 3 }, dc: {} },
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
			name: "Shore + Generator + Solar, Shore active",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3, connected: 1 },
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", serviceName: "com.victronenergy.genset.ttyUSB0", phaseCount: 3 },
			],
			solar: { chargers: [ { phaseCount: 1 }, { power: 456 }, { power: 234 } ] },
		},
		{
			name: "Shore + Generator + Solar, Generator active",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3 },
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", serviceName: "com.victronenergy.genset.ttyUSB0", phaseCount: 3, connected: 1 },
			],
			solar: { chargers: [ { phaseCount: 1 }, { power: 456 }, { power: 234 } ] },
		},
		{
			name: "Shore + Generator with 3-phase, with 5 left-hand widgets in total",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", serviceName: "com.victronenergy.vebus.ttyUSB0", phaseCount: 3 },
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", serviceName: "com.victronenergy.genset.ttyUSB0", phaseCount: 3, connected: 1 },
			],
			dcInputs: {  types: [ { serviceType: "alternator", monitorMode: -1 }, { serviceType: "dcsource", monitorMode: -8 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, ac: { phaseCount: 3 }, dc: {} },
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
