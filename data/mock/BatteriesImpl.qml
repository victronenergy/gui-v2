/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Configures the battery-related mock values based on the battery-type devices on the system.

	Services with a /Dc/[0-9] path and matching "batteryServiceTypes" are added to:
	- system /AvailableBatteries, /AvailableBatteryMeasurements, /AvailableBatteryServices
	- settings /Settings/SystemSetup/Batteries/Configuration with Enabled=1

	The active battery monitor (as per com.victronenergy.system/ActiveBatteryService) is used to
	update the values in com.victronenergy.system/Dc/Battery/.

	If the active battery monitor and active BMS service are not set, and the settings is configured
	to allow the system to auto-select it, then:
	- The active battery monitor is set to the first battery that is found
	- The active BMS service is set to the first BMS-enabled service that is found
*/
Item {
	id: root

	readonly property var batteryServiceTypes: ["battery", "dcsource"]

	function setSystemValue(path, value) {
		MockManager.setValue("com.victronenergy.system" + path, value)
	}
	function systemValue(path) {
		return MockManager.value("com.victronenergy.system" + path)
	}
	function settingsValue(path) {
		return MockManager.value("com.victronenergy.settings" + path)
	}

	function setDefaultBatteryMonitor(battery) {
		// If the active battery monitor is not set, and the settings indicate the system should
		// select one by default, then set it to this battery.
		const canAutoSelect = settingsValue("/Settings/SystemSetup/BatteryService") === "default"
		if (canAutoSelect && !activeBatteryService.valid) {
			console.warn("Mock: auto-set active battery to", battery.portableIdWithInstance(), battery.name)
			activeBatteryService.setValue(battery.portableIdWithInstance())
		}
		// Also set the name of the auto-selected battery, if not already set.
		if (canAutoSelect
				&& !root.systemValue("/AutoSelectedBatteryService")
				&& activeBatteryService.value === battery.portableIdWithInstance()) {
			root.setSystemValue("/AutoSelectedBatteryService", battery.name)
		}
	}

	function setDefaultBmService(battery) {
		// If the active BMS service is not set, and the settings indicate the system should
		// select one by default, then set it to this battery (if it has BMS capabilities).
		const canAutoSelect = settingsValue("/Settings/SystemSetup/BmsInstance") === -1
		if (canAutoSelect && !activeBmsService.valid) {
			console.warn("Mock: auto-set active BMS service to", battery.serviceUid, "with instance", battery.deviceInstance)
			activeBmsService.setValue(battery.serviceUid)
			root.setSystemValue("/ActiveBmsInstance", battery.deviceInstance)
		}
	}

	VeQuickItem {
		id: activeBatteryService
		uid: Global.system.serviceUid + "/ActiveBatteryService"
	}

	VeQuickItem {
		id: activeBmsService
		uid: Global.system.serviceUid + "/ActiveBmsService"
	}

	VeQuickItem {
		id: availableBmsServices

		function addBattery(battery) {
			let services = valid ? value : []
			services.push({ instance: battery.deviceInstance, name: battery.name })
			setValue(services)
		}

		uid: Global.system.serviceUid + "/AvailableBmsServices"
	}

	// Set system /Batteries (a list of objects). Example value:
	// [{'active_battery_service': 1,'current': 55,'id': com.victronenergy.battery.ttyO0,'instance': 256,'name': House battery,'power': 1337,'soc': 98.4,'state': 1,'timetogo': 38040,'voltage': 24.3}]
	// Only 'id', 'name' and 'active_battery_service' are guaranteed to be present for each battery.
	VeQuickItem {
		id: batteries

		property var batteryList: []

		// Returns e.g. "com.victronenergy.battery.ttyUSB1", or "com.victronenergy.battery.ttyUSB1:1"
		// for a virtual battery with channel=1.
		function idFromServiceUid(battery) {
			return battery.serviceUid.substring(battery.serviceUid.indexOf("com.victronenergy")) // strip "mock"
					+ (battery.channel > 0 ? ":" + battery.channel : "")
		}

		function addBattery(battery) {
			let properties = {
				active_battery_service: activeBatteryService.value === battery.portableIdWithInstance(),
				id: idFromServiceUid(battery),
				name: battery.name,
			}
			if (battery.channel === 0 && battery.deviceInstance >= 0) {
				// Device instance is only valid when the channel is not set.
				properties["instance"] = battery.deviceInstance
			}
			batteryList.push(_updatedBatteryProperties(properties, battery))
			setValue(batteryList)
		}

		function removeBattery(battery,) {
			const id = idFromServiceUid(battery)
			for (let i = 0; i < batteryList.length; ++i) {
				if (batteryList[i].id === id) {
					batteryList.splice(i, 1)
					break
				}
			}
			setValue(batteryList)
		}

		function updateBattery(battery) {
			const id = idFromServiceUid(battery)
			for (let i = 0; i < batteryList.length; ++i) {
				if (batteryList[i].id === id) {
					batteryList[i] = _updatedBatteryProperties(batteryList[i], battery)
					setValue(batteryList)
					break
				}
			}
		}

		function _updatedBatteryProperties(properties, battery) {
			for (const propertyName of ["current", "power", "soc", "temperature", "timetogo", "voltage"]) {
				const propertyValue = battery[propertyName].value
				if (propertyValue == null) {
					delete properties[propertyName]
				} else {
					properties[propertyName] = propertyValue
				}
			}
			properties["name"] = battery.name
			return properties
		}

		uid: Global.system.serviceUid + "/Batteries"
	}

	// Set system /AvailableBatteries (type is string). Example value:
	// '{"com.victronenergy.battery/1": {"name": "House battery 1", "channel": null, "type": "battery"}, "com.victronenergy.vebus/257": {"name": "Quattro 24/3000/70-2x50", "channel": null, "type": "vebus"} }'
	VeQuickItem {
		id: availableBatteries

		property var batteryMap: ({})

		function addBattery(battery) {
			batteryMap[battery.portableIdWithInstance()] = {
				name: battery.name,
				channel: battery.channel > 0 ? battery.channel : null,
				type: BackendConnection.serviceTypeFromUid(battery.serviceUid)
			}
			setValue(JSON.stringify(batteryMap))
		}

		function removeBattery(battery) {
			delete batteryMap[battery.portableIdWithInstance()]
			setValue(JSON.stringify(batteryMap))
		}

		uid: Global.system.serviceUid + "/AvailableBatteries"
	}

	// Set system /AvailableBatteryServices (type is string). Example value:
	// `{"default": "Automatic", "nobattery": "No battery monitor", "com.victronenergy.vebus/257": "Quattro 24/3000/70-2x50 on VE.Bus" }`
	VeQuickItem {
		id: availableBatteryServices

		property var batteryServices: {"default": "Automatic", "nobattery": "No battery monitor"}

		function addBattery(battery) {
			batteryServices[battery.portableIdWithInstance()] = battery.name
			setValue(JSON.stringify(batteryServices))
		}

		function removeBattery(battery) {
			delete batteryServices[battery.portableIdWithInstance()]
			setValue(JSON.stringify(batteryServices))
		}

		uid: Global.system.serviceUid + "/AvailableBatteryServices"
	}

	// Set system /AvailableBatteryMeasurements (type is object). Example value:
	// {"com_victronenergy_battery_0/Dc/0":"House battery total","com_victronenergy_battery_1/Dc/0":"House battery 1"}
	VeQuickItem {
		id: availableBatteryMeasurements

		property var batteryNames: ({})

		function normalizedId(battery) {
			return battery.portableIdWithInstance().replace(/\//g, "_").replace(/\./g, "_")
					+ `/Dc/${battery.channel}`
		}

		function addBattery(battery) {
			batteryNames[normalizedId(battery)] = battery.name
			setValue(batteryNames)
		}

		function removeBattery(battery) {
			delete batteryNames[normalizedId(battery)]
			setValue(batteryNames)
		}

		uid: Global.system.serviceUid + "/AvailableBatteryMeasurements"
	}

	// Set settings /Settings/SystemSetup/Batteries/Configuration/*. Example values for a battery
	// service with instance=1:
	// "/Settings/SystemSetup/Batteries/Configuration/com_victronenergy_battery/1/Enabled": 1,
	// "/Settings/SystemSetup/Batteries/Configuration/com_victronenergy_battery/1/Name": "",
	// "/Settings/SystemSetup/Batteries/Configuration/com_victronenergy_battery/1/Service": "com.victronenergy.battery/1",
	QtObject {
		id: batteriesConfiguration

		property var batteryNames: ({})

		function configPath(battery) {
			const batteryId = battery.portableIdWithInstance().replace(/\./g, "_")
			return `${Global.systemSettings.serviceUid}/Settings/SystemSetup/Batteries/Configuration/${batteryId}`
		}

		function addBattery(battery) {
			const prefix = configPath(battery)
			MockManager.setValue(`${prefix}/Enabled`, 1)
			MockManager.setValue(`${prefix}/Name`, "")
			MockManager.setValue(`${prefix}/Service`, battery.portableIdWithInstance())
		}

		function removeBattery(battery) {
			const prefix = configPath(battery)
			for (const path of ["/Enabled", "/Name", "/Service"]) {
				MockManager.removeValue(`${prefix}/path`)
			}
		}
	}

	// Find Battery entries on the system.
	Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterFlags: VeQItemSortTableModel.FilterOffline
			filterRegExp: "^mock/com\.victronenergy\.(%1)\.\\w+\/Dc\/\\d+$".arg(root.batteryServiceTypes.join("|"))
			model: VeQItemTableModel {
				uids: BackendConnection.uidPrefix()
				flags: VeQItemTableModel.AddAllChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}
		delegate: Device {
			id: battery

			required property string uid
			required property string id

			// Channel comes from /Dc/<channel>. Normally the channel is 0, unless there are
			// multiple batteries on the service.
			property int channel: parseInt(id)

			// Returns e.g. "com.victronenergy.battery/289" or "com.victronenergy.vebus/289".
			// Note there is no service suffix like ttyO1, etc.
			// If there is a channel, it is added on the end, e.g. "com.victronenergy.battery/289/1"
			// for a battery with channel=1.
			function portableIdWithInstance() {
				const portableId = BackendConnection.serviceUidToPortableId(serviceUid, deviceInstance)
				return battery.channel > 0 ? `${portableId}/${battery.channel}` : portableId
			}

			function hasBmses() {
				return numberOfBmses.valid && numberOfBmses.value > 0
			}

			function syncBatteryInfo() {
				if (battery.valid) {
					batteries.updateBattery(battery)

					// If this is the active system battery, update /Dc/Battery/* values as well.
					if (activeBatteryService.valid && activeBatteryService.value === portableIdWithInstance()) {
						const properties = {
							"current": "/Dc/Battery/Current",
							"power": "/Dc/Battery/Power",
							"soc": "/Dc/Battery/Soc",
							"temperature": "/Dc/Battery/Temperature",
							"timetogo": "/Dc/Battery/TimeToGo",
							"voltage": "/Dc/Battery/Voltage",
						}
						for (const propertyName in properties) {
							root.setSystemValue(properties[propertyName], battery[propertyName].value)
						}
					}
				}
			}

			serviceUid: uid.substring(0, uid.indexOf("/Dc/"))

			// If there is a channel, the custom/product name comes from the /Devices sub-path
			// instead.
			_customName.uid: channel > 0 ? `${serviceUid}/Devices/${channel}/CustomName` : `${serviceUid}/CustomName`
			_productName.uid: channel > 0 ? `${serviceUid}/Devices/${channel}/ProductName` : `${serviceUid}/ProductName`

			readonly property BatteryProperty current: BatteryProperty { path: `/Dc/${battery.channel}/Current` }
			readonly property BatteryProperty power: BatteryProperty { path: `/Dc/${battery.channel}/Power` }
			readonly property BatteryProperty soc: BatteryProperty { path: battery.channel > 0 ? "" : "/Soc" }
			readonly property BatteryProperty temperature: BatteryProperty { path: `/Dc/${battery.channel}/Temperature` }
			readonly property BatteryProperty timetogo: BatteryProperty { path: battery.channel > 0 ? "" : "/TimeToGo" }
			readonly property BatteryProperty voltage: BatteryProperty { path: `/Dc/${battery.channel}/Voltage` }
			onNameChanged: Qt.callLater(battery.syncBatteryInfo)

			component BatteryProperty: VeQuickItem {
				required property string path
				uid: path && battery.valid ? `${battery.serviceUid}${path}` : ""
				onValueChanged: Qt.callLater(battery.syncBatteryInfo)
			}

			readonly property VeQuickItem numberOfBmses: VeQuickItem {
				uid: battery.valid ? `${battery.serviceUid}/NumberOfBmses` : ""
			}
		}
		onObjectAdded: (index, battery) => {
			if (!battery.valid) {
				return
			}

			// If the active system battery has not been set, set it now. Otherwise, the system
			// will not have a battery monitor.
			root.setDefaultBatteryMonitor(battery)

			// If the active BMS service has not been set, set it to this battery if possible.
			if (battery.hasBmses()) {
				root.setDefaultBmService(battery)
				availableBmsServices.addBattery(battery)
			}

			availableBatteries.addBattery(battery)
			availableBatteryServices.addBattery(battery)
			availableBatteryMeasurements.addBattery(battery)
			batteries.addBattery(battery)
			batteriesConfiguration.addBattery(battery)
		}
		onObjectRemoved: (index, battery) => {
			if (battery.valid) {
				availableBatteries.removeBattery(battery)
				availableBatteryServices.removeBattery(battery)
				availableBatteryMeasurements.removeBattery(battery)
				batteries.removeBattery(battery)
				batteriesConfiguration.removeBattery(battery)
			}
		}
	}
}
