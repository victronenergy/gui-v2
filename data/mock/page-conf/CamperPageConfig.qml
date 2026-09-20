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
			name: "Parking",
			alternatorActive: false,
			generatorPresent: true,
			generatorActive: false,
			shorePowerConnected: false,
			solarPresent: true,
			solarActive: false,
		},
		{
			name: "Parking, with solar",
			alternatorActive: false,
			generatorActive: false,
			shorePowerConnected: false,
			solarActive: true,
		},
		{
			name: "Charging",
			alternatorActive: false,
			shorePowerConnected: true,
			generatorActive: false,
			solarActive: false,
		},
		{
			name: "Driving",
			alternatorActive: true,
			shorePowerConnected: false,
			generatorActive: false,
			solarActive: false,
		},
		{
			name: "Driving, with solar",
			alternatorActive: true,
			shorePowerConnected: false,
			generatorActive: false,
			solarActive: true,
		},
		{
			name: "Off Grid",
			alternatorActive: false,
			shorePowerConnected: false,
			generatorActive: true,
			solarActive: false,
		},
		{
			name: "Off Grid, with solar",
			alternatorActive: false,
			shorePowerConnected: false,
			generatorActive: true,
			solarActive: true,
		},
		{
			name: "Off Grid, discharging",
			alternatorActive: false,
			shorePowerConnected: false,
			generatorActive: false,
			solarActive: false,
		},
	]

	function configCount() {
		return configs.length
	}

	function loadConfig(configIndex) {
		const config = configs[configIndex]
		if (!config) return

		// Remove set values
		MockManager.setValue(Global.system.serviceUid + "/Ac/In/1/Source", VenusOS.AcInputs_InputSource_Shore)
		MockManager.setValue(Global.system.serviceUid + "/Ac/ActiveIn/Source", VenusOS.AcInputs_InputSource_Shore)

		// Add new services if needed
		let deviceInstance
		let serviceUid
		if (config.shorePowerConnected) {
			MockManager.setValue(Global.system.serviceUid + "/Ac/In/1/Source", VenusOS.AcInputs_InputSource_Shore)
			MockManager.setValue(Global.system.serviceUid + "/Ac/ActiveIn/Source", VenusOS.AcInputs_InputSource_Shore)
			MockManager.setValue(MockManager.value(Global.system.serviceUid + "/Ac/In/1/ServiceName") + "/Ac/NumberOfPhases", 1)
		} else {
			MockManager.setValue(Global.system.serviceUid + "/Ac/In/1/Source", VenusOS.AcInputs_InputSource_NotAvailable)
			MockManager.setValue(Global.system.serviceUid + "/Ac/ActiveIn/Source", VenusOS.AcInputs_InputSource_NotAvailable)
			MockManager.setValue(MockManager.value(Global.system.serviceUid + "/Ac/In/1/ServiceName") + "/Ac/NumberOfPhases", 0)
		}
		if (config.generatorActive) {
			MockManager.setValue(Global.system.serviceUid + "/Settings/MonitorMode", -1)
			MockManager.setValue(Global.system.serviceUid + "/Dc/0/Power",  Math.random() * 500)
			MockManager.setValue(Global.system.serviceUid + "/Dc/0/Voltage", Math.random() * 50)
			MockManager.setValue(Global.system.serviceUid + "/Dc/0/Current", Math.random() * 10)
			MockManager.setValue(Global.system.serviceUid + "/Dc/In/P", Math.random() * 500)
			MockManager.setValue(Global.system.serviceUid + "/Dc/In/V", Math.random() * 50)
			MockManager.setValue(Global.system.serviceUid + "/Dc/In/I", Math.random() * 10)
		} else {
			MockManager.setValue(Global.system.serviceUid + "/Settings/MonitorMode", 0)
			MockManager.setValue(Global.system.serviceUid + "/Dc/0/Power",  0)
			MockManager.setValue(Global.system.serviceUid + "/Dc/0/Voltage", 0)
			MockManager.setValue(Global.system.serviceUid + "/Dc/0/Current", 0)
			MockManager.setValue(Global.system.serviceUid + "/Dc/In/P", 0)
			MockManager.setValue(Global.system.serviceUid + "/Dc/In/V", 0)
			MockManager.setValue(Global.system.serviceUid + "/Dc/In/I", 0)
		}
		if (config.generatorActive) {
		} else {
		}

		return config.name
	}

	function createDevice(serviceType, deviceInstance, properties) {
		const serviceUid = "mock/com.victronenergy.%1.mock_camper_config_%2".arg(serviceType).arg(deviceInstance)
		for (const path in properties) {
			MockManager.setValue(serviceUid + path, properties[path])
		}
		MockManager.setValue(serviceUid + "/DeviceInstance", deviceInstance)
		const productName = properties["/ProductName"] ?? serviceType + " " + deviceInstance
		MockManager.setValue(serviceUid + "/ProductName", productName)
		return serviceUid
	}

	objectName: "CamperPageConfig"

	// FilteredServiceModel {
	// 	id: gpsServices
	// 	serviceTypes: ["gps"]
	// }

	// FilteredServiceModel {
	// 	id: motorDriveServices
	// 	serviceTypes: ["motordrive"]
	// }

	FilteredDeviceModel {
		id: dcInputModel
		serviceTypes: ["alternator", "fuelcell", "dcsource", "dcgenset"]
	}
}
