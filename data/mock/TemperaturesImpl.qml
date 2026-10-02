/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function settingsValue(path) {
		return MockManager.value("com.victronenergy.settings" + path)
	}

	// Finds all services with /Dc/<0-9>/Temperature values, and:
	// - sets settings /SystemSetup/TemperatureService to the first service found
	// - adds all services to system /AvailableTemperatureServices
	Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterFlags: VeQItemSortTableModel.FilterOffline
			filterRegExp: "^mock/com\.victronenergy\.\\w+\.\\w+\/Dc\/\\d+/Temperature$"
			model: VeQItemTableModel {
				uids: BackendConnection.uidPrefix()
				flags: VeQItemTableModel.AddAllChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}
		delegate: Device {
			id: temperatureService

			// uid includes path, e.g. "mock/com.victronenergy.vebus/257/Dc/0/Temperature"
			required property string uid

			// Returns e.g. "com.victronenergy.vebus/257/Dc/0/Temperature"
			function serviceIdWithPath() {
				const path = uid.substring(uid.indexOf("/Dc"))
				return BackendConnection.serviceUidToPortableId(serviceUid, deviceInstance) + path
			}

			serviceUid: uid.substring(0, uid.indexOf("/Dc/"))
		}

		onObjectAdded: (index, temperatureService) => {
			// If the auto-selected temperature service is not set, and the settings indicate the system
			// should select one by default, then set it to this service.
			const canAutoSelect = root.settingsValue("/Settings/SystemSetup/TemperatureService") === "default"
			if (canAutoSelect && !autoSelectedTemperatureService.valid) {
				console.warn("Mock: auto-set temperature service to", temperatureService.serviceIdWithPath(), temperatureService.name)
				autoSelectedTemperatureService.setValue(temperatureService.name)
			}
			availableTemperatureServices.addService(temperatureService)
		}
		onObjectRemoved: (index, temperatureService) => {
			availableTemperatureServices.removeService(temperatureService)
		}
	}

	VeQuickItem {
		id: autoSelectedTemperatureService
		uid: Global.system.serviceUid + "/AutoSelectedTemperatureService"
	}

	// Set system /AvailableTemperatureServices (type is object). Example value:
	// {"default":"Automatic","nosensor":"No sensor","com.victronenergy.battery/2/Dc/0/Temperature":"Lynx Smart BMS NG on VE.Can","com.victronenergy.vebus/257/Dc/0/Temperature":"Quattro 24/3000/70-2x50 on VE.Bus"}
	VeQuickItem {
		id: availableTemperatureServices

		property var temperatureServices: {"default": "Automatic", "nosensor": "No sensor"}

		function addService(temperatureService) {
			temperatureServices[temperatureService.serviceIdWithPath()] = temperatureService.name
			setValue(JSON.stringify(temperatureServices))
		}

		function removeService(temperatureService) {
			delete temperatureServices[temperatureService.serviceIdWithPath()]
			setValue(JSON.stringify(temperatureServices))
		}

		uid: Global.system.serviceUid + "/AvailableTemperatureServices"
	}

	// Animate temperature service values.
	Instantiator {
		model: FilteredServiceModel { serviceTypes: ["temperature"] }
		delegate: Item {
			id: temperature

			required property string uid

			MockDataRandomizer {
				active: Global.mainView && Global.mainView.mainViewVisible
				VeQuickItem { uid: temperature.uid + "/Temperature" }
				VeQuickItem { uid: temperature.uid + "/Humidity" }
			}

			// Sensors with a sequence number (e.g. Ruuvi) increment it on each new measurement.
			// The air quality card shows the sensor as offline when it stops changing.
			Timer {
				running: seqNo.valid && Global.mainView && Global.mainView.mainViewVisible
				repeat: true
				interval: 10000
				onTriggered: seqNo.setValue((seqNo.value + 1) % 65536)
			}

			VeQuickItem {
				id: seqNo
				uid: temperature.uid + "/SeqNo"
			}

			// Air quality sensors (e.g. Ruuvi Air) cycle through PM2.5/CO2 values that give each
			// of the air quality categories, from Excellent to Very poor.
			Timer {
				property int step

				readonly property var samples: [
					{ pm25: 2, co2: 450 },
					{ pm25: 6, co2: 600 },
					{ pm25: 12, co2: 900 },
					{ pm25: 25, co2: 1300 },
					{ pm25: 55, co2: 2100 },
				]

				// Same calculation as dbus-ble-sensors (ruuvi_calc_iaqs()).
				function iaqs(pm25, co2) {
					const dx = Math.min(Math.max(pm25, 0), 60) * (100 / 60)
					const dy = (Math.min(Math.max(co2, 420), 2300) - 420) * (100 / 1880)
					return Math.round(100 - Math.min(Math.sqrt(dx * dx + dy * dy), 100))
				}

				running: iaqsItem.valid && Global.mainView && Global.mainView.mainViewVisible
				repeat: true
				interval: 10000
				onTriggered: {
					step = (step + 1) % samples.length
					const sample = samples[step]
					pm25Item.setValue(sample.pm25)
					co2Item.setValue(sample.co2)
					iaqsItem.setValue(iaqs(sample.pm25, sample.co2))
				}
			}

			VeQuickItem {
				id: iaqsItem
				uid: temperature.uid + "/IAQS"
			}

			VeQuickItem {
				id: pm25Item
				uid: temperature.uid + "/PM25"
			}

			VeQuickItem {
				id: co2Item
				uid: temperature.uid + "/CO2"
			}
		}
	}
}
