/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Sets temperature values for the system services.

	Services with /Dc/<0-9>/Temperature are assumed to be temperature services, and are added to
	system /AvailableTemperatureServices.
*/
Item {
	id: root

	function settingsValue(path) {
		return MockManager.value("com.victronenergy.settings" + path)
	}

	function setAutoSelectedTemperatureService(temperatureService) {
		// If the auto-selected temperature service is not set, and the settings indicate the system
		// should select one by default, then set it to this service.
		const canAutoSelect = settingsValue("/Settings/SystemSetup/TemperatureService") === "default"
		if (canAutoSelect && !autoSelectedTemperatureService.valid) {
			console.warn("Mock: auto-set temperature service to", temperatureService.serviceIdWithPath(), temperatureService.name)
			autoSelectedTemperatureService.setValue(temperatureService.name)
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
			root.setAutoSelectedTemperatureService(temperatureService)
			availableTemperatureServices.addService(temperatureService)
		}
		onObjectRemoved: (index, temperatureService) => {
			availableTemperatureServices.removeService(temperatureService)
		}
	}

}
