/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A configuration for each of the states of the RV illustration.

	These set the paths that a real system publishes, and use fixed values so that captures of
	these configurations are reproducible.
*/
Item {
	id: root

	readonly property string _solarServiceUid: "com.victronenergy.solarcharger.camper"
	readonly property string _alternatorServiceUid: "com.victronenergy.alternator.ttyUSB0"
	readonly property string _batteryServiceUid: "com.victronenergy.battery.ttyUSB1"
	readonly property string _veBusServiceUid: "com.victronenergy.vebus.ttyS2"

	readonly property var configs: [
		{
			name: "Shore charging",
			source: VenusOS.AcInputs_InputSource_Shore,
			inputPower: 1850, batteryPower: 560, soc: 80, solar: 320, dc: 210, ac: 1080,
		},
		{
			name: "Pass-through",
			source: VenusOS.AcInputs_InputSource_Shore,
			inputPower: 1080, batteryPower: 0, soc: 100, dc: 210, ac: 1080,
		},
		{
			name: "Grid charging",
			source: VenusOS.AcInputs_InputSource_Grid,
			inputPower: 1850, batteryPower: 560, soc: 80, dc: 210, ac: 1080,
		},
		{
			name: "Driving",
			source: VenusOS.AcInputs_InputSource_Inverting,
			alternatorState: 4, alternatorPower: 620, batteryPower: 480, soc: 60, solar: 320, dc: 210,
		},
		{
			name: "Parked",
			source: VenusOS.AcInputs_InputSource_Inverting,
			alternatorState: 0, batteryPower: -780, soc: 50, solar: 320, dc: 210, ac: 890,
		},
		{
			name: "Off-grid, discharging (no alternator state)",
			source: VenusOS.AcInputs_InputSource_Inverting,
			batteryPower: -780, soc: 50, solar: 320, dc: 210, ac: 890,
		},
		{
			name: "Generator running",
			source: VenusOS.AcInputs_InputSource_Generator,
			inputPower: 2600, batteryPower: 900, soc: 40, dc: 210, ac: 1400,
		},
		{
			name: "Solar only",
			source: VenusOS.AcInputs_InputSource_Inverting,
			alternatorState: 0, noGenerator: true, batteryPower: 300, soc: 80, solar: 620, dc: 210, ac: 110,
		},
		{
			name: "Low battery alarm",
			source: VenusOS.AcInputs_InputSource_Inverting,
			alternatorState: 0, lowSocAlarm: 2, batteryPower: -320, soc: 12, solar: 0, dc: 320, ac: 0,
		},
		{
			name: "No solar panels",
			source: VenusOS.AcInputs_InputSource_Shore,
			noSolar: true, inputPower: 1850, batteryPower: 560, soc: 80, dc: 210, ac: 1080,
		},
		{
			name: "No solar panels, no generator",
			source: VenusOS.AcInputs_InputSource_Shore,
			noSolar: true, noGenerator: true, inputPower: 1850, batteryPower: 560, soc: 80, dc: 210, ac: 1080,
		},
		{
			name: "No values available",
			source: VenusOS.AcInputs_InputSource_NotAvailable,
			noSolar: true, noGenerator: true,
		},
	]

	function configCount() {
		return configs.length
	}

	function loadConfig(configIndex) {
		const config = configs[configIndex]
		if (!config) return

		const systemUid = Services.system.serviceUid
		const generatorActive = config.source === VenusOS.AcInputs_InputSource_Generator
		const externalActive = config.source === VenusOS.AcInputs_InputSource_Shore
				|| config.source === VenusOS.AcInputs_InputSource_Grid

		MockManager.setValue(systemUid + "/Ac/ActiveIn/Source", config.source)
		MockManager.setValue(systemUid + "/Ac/In/0/Source", config.source === VenusOS.AcInputs_InputSource_Grid
				? VenusOS.AcInputs_InputSource_Grid : VenusOS.AcInputs_InputSource_Shore)
		MockManager.setValue(systemUid + "/Ac/In/0/Connected", externalActive ? 1 : 0)
		MockManager.setValue(systemUid + "/Ac/In/1/Source", config.noGenerator
				? VenusOS.AcInputs_InputSource_NotAvailable : VenusOS.AcInputs_InputSource_Generator)
		MockManager.setValue(systemUid + "/Ac/In/1/Connected", generatorActive ? 1 : 0)
		MockManager.setValue(_veBusServiceUid + "/Ac/ActiveIn/L1/P", config.inputPower ?? undefined)
		MockManager.setValue(_veBusServiceUid + "/Ac/ActiveIn/L2/P", undefined)
		MockManager.setValue(_veBusServiceUid + "/Ac/ActiveIn/L3/P", undefined)

		MockManager.setValue(_alternatorServiceUid + "/State", config.alternatorState ?? undefined)
		MockManager.setValue(_alternatorServiceUid + "/Dc/0/Power", config.alternatorPower ?? 0)
		MockManager.setValue(_batteryServiceUid + "/Alarms/LowSoc", config.lowSocAlarm ?? 0)

		if (config.noSolar) {
			if (MockManager.value(_solarServiceUid + "/DeviceInstance") !== undefined) {
				MockManager.removeValue(_solarServiceUid)
			}
		} else {
			MockManager.setValue(_solarServiceUid + "/DeviceInstance", 256)
			MockManager.setValue(_solarServiceUid + "/ProductName", "SmartSolar")
			MockManager.setValue(_solarServiceUid + "/Connected", 1)
			// SolarInputsImpl derives the system PV power from the solar chargers.
			MockManager.setValue(_solarServiceUid + "/Yield/Power", config.solar ?? undefined)
		}

		MockManager.setValue(systemUid + "/Dc/Battery/Power", config.batteryPower ?? undefined)
		MockManager.setValue(systemUid + "/Dc/Battery/Soc", config.soc ?? undefined)
		MockManager.setValue(systemUid + "/Dc/System/Power", config.dc ?? undefined)
		// SystemAcImpl derives the system AC consumption values from the vebus output.
		MockManager.setValue(_veBusServiceUid + "/Ac/Out/L1/P", config.ac ?? undefined)
		MockManager.setValue(_veBusServiceUid + "/Ac/Out/L2/P", undefined)
		MockManager.setValue(_veBusServiceUid + "/Ac/Out/L3/P", undefined)

		return config.name
	}

	objectName: "CamperPageConfig"
}
