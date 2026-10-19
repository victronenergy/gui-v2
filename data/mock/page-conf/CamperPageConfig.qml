/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property int mockDeviceCount

	readonly property var configs: [
		{
			name: "Driving (solar and generator), alternator active",
			alternatorActive: true,
			generatorPresent: true,
			generatorActive: false,
			shorePowerConnected: false,
			solarPresent: true,
			solarActive: false,
			acLoad: false,
			dcLoad: true,
		},
		{
			name: "Driving (solar only), alternator active",
			alternatorActive: true,
			generatorPresent: false,
			generatorActive: false,
			shorePowerConnected: false,
			solarPresent: true,
			solarActive: false,
			acLoad: false,
			dcLoad: true,
		},
		{
			name: "Driving (generator only), alternator active",
			alternatorActive: true,
			generatorPresent: true,
			generatorActive: false,
			shorePowerConnected: false,
			solarPresent: false,
			solarActive: false,
			acLoad: false,
			dcLoad: true,
		},
		{
			name: "Off Grid (solar and generator), generator active",
			alternatorActive: false,
			generatorPresent: true,
			generatorActive: true,
			shorePowerConnected: false,
			solarPresent: true,
			solarActive: false,
			acLoad: true,
			dcLoad: false,
		},
		{
			name: "Off Grid (solar and generator), generator and solar active",
			alternatorActive: false,
			generatorPresent: true,
			generatorActive: true,
			shorePowerConnected: false,
			solarPresent: true,
			solarActive: true,
			acLoad: true,
			dcLoad: true,
		},
		{
			name: "Off Grid (solar and generator), nothing active",
			alternatorActive: false,
			generatorPresent: true,
			generatorActive: false,
			shorePowerConnected: false,
			solarPresent: true,
			solarActive: false,
			acLoad: false,
			dcLoad: false,
		},
		{
			name: "Parking (solar and generator), nothing active",
			alternatorActive: false,
			generatorPresent: true,
			generatorActive: false,
			shorePowerConnected: false,
			solarPresent: true,
			solarActive: false,
			acLoad: false,
			dcLoad: false,
		},
		{
			name: "Parking (solar and generator), solar active",
			alternatorActive: false,
			generatorPresent: true,
			generatorActive: false,
			shorePowerConnected: false,
			solarPresent: true,
			solarActive: true,
			acLoad: false,
			dcLoad: true,
		},
		{
			name: "Charging (solar and generator), shore active",
			alternatorActive: false,
			generatorPresent: true,
			generatorActive: false,
			shorePowerConnected: true,
			solarPresent: true,
			solarActive: false,
			acLoad: true,
			dcLoad: true,
		},
		{
			name: "Charging (solar only), shore active",
			alternatorActive: false,
			generatorPresent: false,
			generatorActive: false,
			shorePowerConnected: true,
			solarPresent: true,
			solarActive: false,
			acLoad: true,
			dcLoad: true,
		},
		{
			name: "Charging (generator only ), shore active",
			alternatorActive: false,
			generatorPresent: true,
			generatorActive: false,
			shorePowerConnected: true,
			solarPresent: false,
			solarActive: false,
			acLoad: true,
			dcLoad: true,
		},
	]

	function configCount() {
		return configs.length
	}

	function loadConfig(configIndex) {
		const config = configs[configIndex]
		if (!config) return

		// Remove set values
		MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/AcPower", config.acLoad ? Math.random() * 1000 : 0)
		MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/DcPower", config.dcLoad ? Math.random() * 500 : 0)
		MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/BatteryPower", 1000)

		// Add new services if needed
		let deviceInstance
		let serviceUid
		if (config.shorePowerConnected) {
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/Shore", 1)
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/ShorePower", Math.random() * 2000)
		} else {
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/Shore", 0)
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/ShorePower", 0)
		}
		if (config.generatorPresent) {
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/Generator", 1)
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/GeneratorPower", 0)
		} else {
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/Generator", 0)
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/GeneratorPower", 0)

		}
		if (config.generatorActive) {
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/GeneratorPower", Math.random() * 2000)
		} else {
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/GeneratorPower", 0)
		}
		if (config.alternatorActive) {
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/AlternatorPower", Math.random() * 2000)

		} else {
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/AlternatorPower", 0)

		}
		if (config.solarPresent) {
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/Solar", 1)
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/SolarPower", 0)

		} else {
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/Solar", 0)
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/SolarPower", 0)

		}
		if (config.solarActive) {
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/SolarPower", Math.random() * 2000)

		} else {
			MockManager.setValue(Global.system.serviceUid + "/Settings/Camper/SolarPower", 0)

		}
		return config.name
	}

	objectName: "CamperPageConfig"
}
