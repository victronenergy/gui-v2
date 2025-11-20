/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides UI configurations to test layouts in Brief and Overview pages.

	This is purely for testing the layout; any devices added by these configurations do not contain
	proper or complete details.
*/
Item {
	id: root

	property int mockDeviceCount

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
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "vebus", phaseCount: 3, connected: 1 },
				emptyAcInput,

			],
			solar: { inverters: [ { phaseCount: 1 } ] },
			system: { state: VenusOS.System_State_Inverting, hasAcOutSystem: 0, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc"] } },
		},
		{
			name: "ESS - AC & DC coupled. 3-phase PV Inverter on AC Out",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "vebus", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			solar: { inverters: [ { phaseCount: 3 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, hasAcOutSystem: 0, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc","dcload"] } },
		},
		// TODO "ESS - AC & DC coupled. PV Inverter on AC Out (Amps version)",
		{
			name: "Phase self consumption",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", productId: ProductInfo.ProductId_Genset_FischerPandaAc, phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			solar: { chargers: [ { power: 300 } ], inverters: [ { phaseCount: 3 } ] },
			system: { state: VenusOS.System_State_PassThrough, hasAcOutSystem: 0, ac: { phaseCount: 3 } },
		},
		{
			name: "Off grid",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			solar: { chargers: [ { power: 300 } ], inverters: [ { phaseCount: 3 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, hasAcOutSystem: 0, ac: { phaseCount: 1 }, dc: { serviceTypes: ["dcload", "dcdc"] } },
		},
		{
			name: "ESS - AC coupled on AC Output",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "vebus", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			solar: { inverters: [ { phaseCount: 3 } ] },
			system: { state: VenusOS.System_State_FloatCharging, hasAcOutSystem: 0, ac: { phaseCount: 1 } },
		},
		{
			name: "Pure Energy Storage - no PV",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "vebus", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			// TODO state should be 'Scheduled charging', but not in dbus API?
			system: { state: VenusOS.System_State_FloatCharging, hasAcOutSystem: 0, ac: { phaseCount: 1 } },
		},
		{
			name: "Combo one (amps): Shore / DC Generator / Left & Right Alternator / Solar",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			dcInputs: {  types: [ { serviceType: "dcsource", monitorMode: -1 }, { serviceType: "alternator", monitorMode: -1 } ] },
			solar: { chargers: [ { power: 300 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, hasAcOutSystem: 0, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc"] } },
		},
		{
			name: "Single-phase Shore",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			system: { state: VenusOS.System_State_AbsorptionCharging, hasAcOutSystem: 0, ac: { phaseCount: 1 }, dc: { serviceTypes: ["dcdc"] } },
		},
		{
			name: "Single phase + solar",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, hasAcOutSystem: 0, ac: { phaseCount: 1 }, dc: { serviceTypes: ["dcsystem"] } },
		},
		{
			name: "Small RV with alternator or small boat",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			dcInputs: {  types: [ { serviceType: "alternator", monitorMode: -1 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, hasAcOutSystem: 0, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcload"] } },
		},
		{
			name: "Catamaran with wind: Shore / Solar / Left alternator / Right alternator / Wind",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			dcInputs: {  types: [ { serviceType: "alternator", monitorMode: -1 }, { serviceType: "dcsource", monitorMode: -8 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, hasAcOutSystem: 0, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc","dcload"] } },
		},
		{
			name: "Boat with DC generator",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			dcInputs: {  types: [ { serviceType: "dcsource", monitorMode: -1 }, { serviceType: "alternator", monitorMode: -1 }, { serviceType: "dcsource", monitorMode: -8 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, hasAcOutSystem: 0, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc","dcload"] } },
		},
		{
			name: "Multiple solar chargers",
			solar: { chargers: [ { phaseCount: 1 }, { power: 456 }, { power: 234 } ] },
		},
		{
			name: "AC Loads + 1 EVCS + DC Loads, 1-phase AC input",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", phaseCount: 1, connected: 1 },
				emptyAcInput,
			],
			system: { state: VenusOS.System_State_FloatCharging, hasAcOutSystem: 0, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc","dcload"] } },
			evcs: { chargers: [ { status: VenusOS.Evcs_Status_Charging, mode: VenusOS.Evcs_Mode_Auto } ] }
		},
		{
			name: "AC Loads + 3 EVCS, 3-phase AC input",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", phaseCount: 3, connected: 1 },
				emptyAcInput,
			],
			system: { state: VenusOS.System_State_FloatCharging, hasAcOutSystem: 0, ac: { phaseCount: 3 } },
			evcs: { chargers: [ { status: VenusOS.Evcs_Status_Charging }, { status: VenusOS.Evcs_Status_Charging }, { status: VenusOS.Evcs_Status_Disconnected } ] },
		},
		{
			name: "Single 3-phase PV inverter, no AC/DC inputs",
			acInputs: [emptyAcInput, emptyAcInput],
			system: { state: VenusOS.System_State_FloatCharging, hasAcOutSystem: 0, ac: { phaseCount: 3 } },
			solar: { inverters: [ { phaseCount: 3 } ] },
		},
		{
			name: "Multiple 1-phase PV inverters, no AC/DC inputs",
			acInputs: [emptyAcInput, emptyAcInput],
			solar: { inverters: [ { phaseCount: 1 }, { phaseCount: 1 }, { phaseCount: 1 } ] },
		},
		{
			name: "Multiple alternators, no AC inputs",
			acInputs: [emptyAcInput, emptyAcInput],
			dcInputs: { types: [ { serviceType: "alternator" }, { serviceType: "alternator" } ] },
		},
		{
			name: "Shore + Generator with 3-phase, with 5 left-hand widgets in total",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", phaseCount: 3, connected: 1 },
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", phaseCount: 3, connected: 0 },
			],
			dcInputs: {  types: [ { serviceType: "alternator", monitorMode: -1 }, { serviceType: "dcsource", monitorMode: -8 } ] },
			solar: { chargers: [ { power: 456 } ] },
			system: { state: VenusOS.System_State_AbsorptionCharging, hasAcOutSystem: 0, ac: { phaseCount: 3 }, dc: { serviceTypes: ["dcdc","dcload"] } },
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
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "vebus", phaseCount: 3, connected: 1 },
				{ source: VenusOS.AcInputs_InputSource_Shore, serviceType: "vebus", phaseCount: 3, connected: 0 },
			]
		},
		{
			// One input (generator) on the Multi/Quattro, other input (grid) on dedicated energy meter.
			// Generator data from com.victronenergy.vebus.<suffix>/Ac/ActiveIn/Lx/{P,V,I,F} (when active).
			// Grid data from com.victronenergy.grid.<suffix>/Ac/Lx/{Power,Voltage,Current}.
			name: "Generator on Multi/Quattro + Grid on energy meter (Grid connected)",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "vebus", phaseCount: 3, connected: 0 },
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "grid", phaseCount: 3, connected: 1 },
			]
		},
		{
			// Same as previous case, but Multi/Quattro input is connected.
			// Generator is connected, but the Grid is the highlighted input.
			// Grid /Connected=0 is ignored because it is an energy meter, not on the Multi/Quattro.
			name: "Generator on Multi/Quattro + Grid on energy meter (Generator not connected, but both operational)",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "vebus", phaseCount: 3, connected: 1 },
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "grid", phaseCount: 3, connected: 0 },
			]
		},
		{
			// Both inputs (generator and grid) are on dedicated energy meters.
			// Generator is connected, but the Grid is the highlighted input.
			// Generator data from com.victronenergy.genset.<suffix>/Ac/ActiveIn/Lx/{Power,Voltage,Current}.
			// Grid data from com.victronenergy.grid.<suffix>/Ac/Lx/{Power,Voltage,Current}.
			// Grid /Connected=0 is ignored because it is an energy meter, not on the Multi/Quattro.
			name: "Generator + Grid on energy meters (Grid not connected, but both operational)",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "genset", phaseCount: 3, connected: 1 },
				{ source: VenusOS.AcInputs_InputSource_Grid, serviceType: "grid", phaseCount: 3, connected: 0},
			]
		},
		{
			// Multi-RS, which only one AC input.
			// Input data comes from com.victronenergy.acsystem.socketcan_can0_vi0_uc162268/Ac/In/1/Lx/{P,V,I,F}.
			name: "Generator on Multi-RS (connected)",
			acInputs: [
				{ source: VenusOS.AcInputs_InputSource_Generator, serviceType: "acsystem", phaseCount: 3, connected: 1 },
				emptyAcInput,
			]
		},
	]

	function configCount() {
		return configs.length
	}

	function loadConfig(configIndex) {
		const config = configs[configIndex]
		setSystem(config.system)
		setAcInputs(config.acInputs)
		setDcInputs(config.dcInputs)
		setSolar(config.solar)
		setEvChargers(config.evcs)
		return config.name
	}

	function setSystem(config) {
		let i
		if (config?.state !== undefined) {
			MockManager.setValue(Global.system.serviceUid + "/SystemState/State", config.state)
		}
		if (config?.showInputLoads !== undefined) {
			MockManager.setValue(Global.system.serviceUid + "/Ac/Grid/DeviceType", config.showInputLoads ? 0 : undefined)
			MockManager.setValue(Global.systemSettings.serviceUid + "/Settings/CGwacs/RunWithoutGridMeter", config.showInputLoads ? 0 : 1)
		}
		if (config?.hasAcOutSystem !== undefined) {
			MockManager.setValue(Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasAcOutSystem", config.hasAcOutSystem ? 1 : 0)
		}
		const phaseCount = config?.ac ? (config.ac.phaseCount ?? 3) : 0

		// Clear the Power/Current values for any phases beyond the requested phase count.
		for (const path of ["/Ac/Consumption", "/Ac/ConsumptionOnInput", "/Ac/ConsumptionOnOutput"]) {
			for (i = 0; i < 3; ++i) {
				const phasePath = Global.system.serviceUid + path + "/L" + (i+1)
				for (const phaseSubPath of ["/Power", "/Current"]) {
					if (i >= phaseCount) {
						MockManager.setValue(phasePath + phaseSubPath, undefined)
					} else {
						MockManager.setValue(phasePath + phaseSubPath, 0)
					}
				}
			}
		}

		// Update the /NumberOfPhases for the system AC load totals.
		for (const acObject of [Global.system.load.ac, Global.system.load.acIn, Global.system.load.acOut]) {
			acObject._phaseCount.setValue(0) // trigger reset of PhaseModel
			acObject._phaseCount.setValue(phaseCount)
		}

		while (dcLoadsModel.count > 0) {
			removeDevice(dcLoadsModel.deviceAt(dcLoadsModel.count - 1).serviceUid)
		}
		const dcServiceTypes = config?.dc?.serviceTypes ?? []
		for (i = 0; i < dcServiceTypes.length; ++i) {
			const values = {
				"/Dc/0/Power": Math.random() * 500,
				"/Dc/0/Voltage": Math.random() * 50,
				"/Dc/0/Current": Math.random() * 10,
			}
			createDevice(dcServiceTypes[i], mockDeviceCount++, values)
		}
	}

	function setAcInputs(config) {
		setAcInputInfo(Global.acInputs.input1Info, config ? config[0] : emptyAcInput)
		setAcInputInfo(Global.acInputs.input2Info, config ? config[1] : emptyAcInput)
	}

	function setAcInputInfo(inputInfo, inputInfoConfig) {
		for (const propertyName of ["source", "serviceType", "connected"]) {
			inputInfo["_" + propertyName].setValue(inputInfoConfig[propertyName])
		}
		if (inputInfoConfig === emptyAcInput) {
			return
		}

		// Set the system /Ac/In/<x> details so that AcInputs.qml detects the new input details
		const device = inputInfoConfig.serviceType === "vebus" ? vebusModel.firstObject
				: inputInfoConfig.serviceType === "genset" ? gensetModel.firstObject
				: inputInfoConfig.serviceType === "grid" ? gridModel.firstObject
				: inputInfoConfig.serviceType === "acsystem" ? acSystemModel.firstObject
				: null
		if (device) {
			inputInfo._deviceInstance.setValue(device.deviceInstance)
			inputInfo._serviceName.setValue(device.serviceUid.substr(5)) // strip "mock/"
		} else {
			const deviceInstance = root.mockDeviceCount++
			const serviceUid = createDevice(inputInfoConfig.serviceType, deviceInstance, {})
			console.warn("No services found for AC input type '%1', added new service: %2".arg(inputInfoConfig.serviceType).arg(serviceUid))
			inputInfo._deviceInstance.setValue(deviceInstance)
			inputInfo._serviceName.setValue(serviceUid.substr(5))
		}
		inputInfo.serviceInfoChanged() // force AcInputs.qml to update the acInput object now, so phases can be set

		// Set the active input for vebus/acsystem inputs
		const input = Global.acInputs["input" + (inputInfo.inputIndex + 1)]
		if (input) {
			if (!!inputInfoConfig.connected && input._activeInput.uid) {
				input._activeInput.setValue(inputInfo.inputIndex)
			}
			// Set phase data
			const objectAcConn = input._phaseMeasurements
			const phaseCount = inputInfoConfig.phaseCount ?? 1
			objectAcConn._phaseCount.setValue(0) // trigger reset of PhaseModel
			objectAcConn._phaseCount.setValue(phaseCount)
			let phaseIndex
			for (phaseIndex = 0; phaseIndex < phaseCount; phaseIndex++) {
				const current = Math.random() * 30
				const voltage = current * 5
				const powerItem = objectAcConn["powerL" + (phaseIndex + 1)]
				if (powerItem?.uid) {
					powerItem.setValue(current * voltage)
				}
				const currentItem = objectAcConn["currentL" + (phaseIndex + 1)]
				if (currentItem?.uid) {
					currentItem.setValue(current)
				}
				if (powerItem?.uid && currentItem?.uid) {
					const voltageKey = inputInfoConfig.serviceType === "vebus" || inputInfoConfig.serviceType === "acsystem" ? "V" : "Voltage"
					MockManager.setValue(`${objectAcConn.bindPrefix}/L${phaseIndex + 1}/${voltageKey}`, voltage)
				}
			}

			// Clear the Power/Current values for any phases beyond the requested phase count.
			for (phaseIndex = phaseCount; phaseIndex < 3; ++phaseIndex) {
				const phasePath = `${objectAcConn.bindPrefix}/L${phaseIndex + 1}`
				MockManager.setValue(phasePath + "/" + objectAcConn.powerKey, undefined)
				MockManager.setValue(phasePath + "/" + objectAcConn.currentKey, undefined)
			}
		}
	}

	function setDcInputs(config) {
		while (dcInputModel.count > 0) {
			removeDevice(dcInputModel.deviceAt(dcInputModel.count - 1).serviceUid)
		}
		if (config?.types) {
			for (let i = 0; i < config.types.length; ++i) {
				const inputConfig = config.types[i]
				const deviceInstanceNum = mockDeviceCount++
				const monitorMode = inputConfig.monitorMode ?? -1
				const values = {
					"/Settings/MonitorMode": monitorMode,
					"/Dc/0/Power": Math.random() * 500,
					"/Dc/0/Voltage": Math.random() * 50,
					"/Dc/0/Current": Math.random() * 10,
					"/Dc/In/P": Math.random() * 500,
					"/Dc/In/V": Math.random() * 50,
					"/Dc/In/I": Math.random() * 10,
				}
				const serviceUid = createDevice(inputConfig.serviceType, deviceInstanceNum, values)
				MockManager.setValue(serviceUid + "/CustomName", "%1 (%2)"
						.arg(inputConfig.serviceType)
						.arg(VenusOS.dcMeter_typeToText(VenusOS.dcMeter_type(inputConfig.serviceType, monitorMode))))
			}
		}
	}

	function setSolar(config) {
		while (solarInputModel.count > 0) {
			removeDevice(solarInputModel.deviceAt(solarInputModel.count - 1).serviceUid)
		}
		if (config) {
			let i
			const pvInverters = config.inverters
			if (pvInverters) {
				for (i = 0; i < pvInverters.length; ++i) {
					const deviceInstanceNum = mockDeviceCount++
					let inverterValues = {
						"/Status": 0,
						"/Connected": 1,
						"/Ac/Energy/Forward": Math.random() * 1000,
						"/Ac/Power": Math.random() * 500,
					}
					const phaseCount = pvInverters[i].phaseCount ?? 1
					for (let phaseIndex = 0; phaseIndex < phaseCount; ++phaseIndex) {
						inverterValues["/Ac/L%1/Power".arg(phaseIndex + 1)] = Math.random() * 500
						inverterValues["/Ac/L%1/Current".arg(phaseIndex + 1)] = Math.random() * 10
						inverterValues["/Ac/L%1/Voltage".arg(phaseIndex + 1)] = Math.random() * 40
						inverterValues["/Ac/L%1/Energy/Forward".arg(phaseIndex + 1)] = Math.random() * 500
					}
					createDevice("pvinverter", deviceInstanceNum, inverterValues)
				}
			}
			const chargers = config.chargers
			if (chargers) {
				for (i = 0; i < chargers.length; ++i) {
					const deviceInstanceNum = mockDeviceCount++
					const historyDaysAvailable = 31
					let chargerValues = {
						"/Pv/V": Math.random() * 30,
						"/Yield/Power": chargers[i].power ?? 0,
						"/History/Overall/DaysAvailable": historyDaysAvailable,
					}
					for (let dayIndex = 0; dayIndex < historyDaysAvailable; ++dayIndex) {
						chargerValues["/History/Daily/%1/Yield".arg(dayIndex)] = Math.random()
					}
					createDevice("solarcharger", deviceInstanceNum, chargerValues)
				}
			}
		}
	}

	function setEvChargers(config) {
		while (evcsModel.count > 0) {
			removeDevice(evcsModel.deviceAt(evcsModel.count - 1).serviceUid)
		}
		if (config?.chargers) {
			for (let i = 0; i < config.chargers.length; ++i) {
				const deviceInstanceNum = mockDeviceCount++
				const values = {
					"/Status": config.chargers[i].status ?? VenusOS.Evcs_Status_Disconnected,
					"/Mode": config.chargers[i].mode ?? VenusOS.Evcs_Mode_Manual,
					"/Position": config.chargers[i].position ?? VenusOS.AcPosition_AcOutput,
					"/StartStop": 1,
					"/AutoStart": 1,
					"/EnableDisplay": 1,
					"/SetCurrent": 16,
					"/Connected": 1,
					"/Ac/Energy/Forward": Math.random() * 1000,
					"/Ac/Power": Math.random() * 500,
					"/Ac/Current": Math.random() * 10,
					"/Session/Energy": Math.random() * 100,
					"/Session/Time": Math.floor(Math.random() * 60)
				}
				createDevice("evcharger", deviceInstanceNum, values)
			}
		}
	}

	function createDevice(serviceType, deviceInstance, properties) {
		const serviceUid = "mock/com.victronenergy.%1.mock_brief_config_%2".arg(serviceType).arg(deviceInstance)
		for (const path in properties) {
			MockManager.setValue(serviceUid + path, properties[path])
		}
		MockManager.setValue(serviceUid + "/DeviceInstance", deviceInstance)
		const productName = properties["/ProductName"] ?? serviceType + " " + deviceInstance
		MockManager.setValue(serviceUid + "/ProductName", productName)
		return serviceUid
	}

	function removeDevice(serviceUid) {
		// Invalidate the device instance so that it will be auto-removed from any DeviceModels.
		MockManager.setValue(serviceUid + "/DeviceInstance", -1)

		// Remove the uid from the mock backend.
		MockManager.removeValue(serviceUid)
	}

	FilteredDeviceModel {
		id: vebusModel
		serviceTypes: ["vebus"]
		sorting: FilteredDeviceModel.DeviceInstance
	}

	FilteredDeviceModel {
		id: gridModel
		serviceTypes: ["grid"]
	}

	FilteredDeviceModel {
		id: gensetModel
		serviceTypes: ["genset"]
	}

	FilteredDeviceModel {
		id: dcInputModel
		serviceTypes: ["alternator", "fuelcell", "dcsource", "dcgenset"]
	}

	FilteredDeviceModel {
		id: acSystemModel
		serviceTypes: ["acsystem"]
	}

	FilteredDeviceModel {
		id: dcLoadsModel
		serviceTypes: ["dcload", "dcsystem", "dcdc"]
	}

	FilteredDeviceModel {
		id: solarInputModel
		serviceTypes: ["solarcharger", "multi", "pvinverter", "inverter"]
	}

	FilteredDeviceModel {
		id: evcsModel
		serviceTypes: ["evcharger"]
	}

}
