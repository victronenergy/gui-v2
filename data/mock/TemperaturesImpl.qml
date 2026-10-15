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

			// The id under which this service is currently listed in
			// /AvailableTemperatureServices, or an empty string if it is not listed.
			property string listedServiceId

			// The name under which this service is currently listed, so that a later change to
			// the name can be detected and the listing updated.
			property string listedName

			// Returns e.g. "com.victronenergy.vebus/257/Dc/0/Temperature"
			function serviceIdWithPath() {
				const path = uid.substring(uid.indexOf("/Dc"))
				return BackendConnection.serviceUidToPortableId(serviceUid, deviceInstance) + path
			}

			// Adds this service to /AvailableTemperatureServices, or updates its entry if its id
			// or name has changed.
			//
			// The service is only listed once it is valid and its name is known; before that, its
			// device instance and name are not known yet, and it would be listed with an invalid
			// device instance and an empty name.
			function updateListing() {
				const serviceId = valid && name.length > 0 ? serviceIdWithPath() : ""
				if (serviceId === listedServiceId && name === listedName) {
					return
				}
				// Only remove the previous listing if it was listed under a different id; if only
				// the name changed, addService() below overwrites the entry under the same id.
				if (listedServiceId.length > 0 && listedServiceId !== serviceId) {
					availableTemperatureServices.removeServiceId(listedServiceId)
				}
				listedServiceId = serviceId
				listedName = name
				if (serviceId.length > 0) {
					availableTemperatureServices.addService(serviceId, name)

					// If the auto-selected temperature service is not set, and the settings
					// indicate the system should select one by default, then set it to this
					// service.
					const canAutoSelect = root.settingsValue("/Settings/SystemSetup/TemperatureService") === "default"
					if (canAutoSelect && !autoSelectedTemperatureService.valid) {
						console.warn("Mock: auto-set temperature service to", serviceId, name)
						autoSelectedTemperatureService.setValue(name)
					}
				}
			}

			serviceUid: uid.substring(0, uid.indexOf("/Dc/"))

			onValidChanged: updateListing()
			onNameChanged: updateListing()
			// The listed id contains the device instance, and Device only emits validChanged when
			// its validity actually flips, so a change from one non-negative instance to another
			// is not covered by onValidChanged.
			onDeviceInstanceChanged: updateListing()
		}

		onObjectRemoved: (index, temperatureService) => {
			if (temperatureService.listedServiceId.length > 0) {
				availableTemperatureServices.removeServiceId(temperatureService.listedServiceId)
			}
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

		function addService(serviceId, name) {
			temperatureServices[serviceId] = name
			setValue(JSON.stringify(temperatureServices))
		}

		function removeServiceId(serviceId) {
			delete temperatureServices[serviceId]
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
		}
	}
}
