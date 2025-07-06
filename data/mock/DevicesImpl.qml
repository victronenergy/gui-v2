/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Configures device-related mock values based on the devices present on the system, including:
	- com.victronenergy.settings/Settings/Devices
	- com.victronenergy.modbustcp/Services

	TODO: update to add com.victronenergy.settings/Settings/Devices/cgwacs_* devices for Carlo
	Gavazzi meters.
*/
Item {
	id: root

	// Sets settings /Settings/Devices/*. Example:
	//      /Settings/Devices/adc_builtin0_8/ClassAndVrmInstance "tank:22"
	//      /Settings/Devices/adc_builtin0_8/CustomName "Fresh water tank"
	QtObject {
		id: settingsDevices

		function addDevice(device) {
			const serviceType = BackendConnection.serviceTypeFromUid(device.serviceUid)
			MockManager.setValue(settingPath(device.serviceUid) + "/ClassAndVrmInstance", serviceType + ":" + device.deviceInstance)
			MockManager.setValue(settingPath(device.serviceUid) + "/CustomName", device.customName)
		}

		function removeDevice(device) {
			MockManager.removeValue(settingPath(device.serviceUid))
		}

		function settingPath(serviceUid) {
			// The identifier is the suffix after the service type. E.g. if the uid is
			// mock/com.victronenergy.temperature.adc_builtin0_8, the uid is "adc_builtin0_8".
			// This does not necessarily how it is done on a real system, but it's close enough
			// for mock mode.
			const serviceType = BackendConnection.serviceTypeFromUid(serviceUid)
			const identifier = serviceUid.substring(serviceUid.indexOf(serviceType) + serviceType.length + 1)
			return Global.systemSettings.serviceUid + "/Settings/Devices/" + identifier
		}
	}

	// Sets modbustcp /Services/*. Example:
	//      /Services/18/ServiceName "com.victronenergy.grid.cgwacs_ttyUSB0_mb2"
	//      /Services/18/UnitId 33
	//      /Services/18/IsActive 1
	QtObject {
		id: modbusTcpServices

		property int deviceCount

		function addDevice(device) {
			const serviceName = device.serviceUid.substring(5)  // remove "mock/"
			const identifier = deviceCount++
			MockManager.setValue(settingPath(identifier) + "/ServiceName", serviceName)
			MockManager.setValue(settingPath(identifier) + "/UnitId", device.deviceInstance)
			MockManager.setValue(settingPath(identifier) + "/IsActive", 1)
			return identifier
		}

		function setInactive(identifier) {
			MockManager.setValue(settingPath(identifier) + "/IsActive", 0)
		}

		function settingPath(identifier) {
			return "mock/com.victronenergy.modbustcp/Services/" + identifier
		}
	}

	Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterFlags: VeQItemSortTableModel.FilterOffline
			model: Global.dataServiceModel

			// Only match services with a suffix after the service type (e.g. match
			// com.victronenergy.vebus.ttyO1 but not com.victronenergy.system).
			filterRegExp: "^mock\/com\\.victronenergy\\.\\w+\\."
		}
		delegate: Device {
			id: device

			required property string uid
			property int modbusTcpId: -1
			serviceUid: uid
		}

		onObjectAdded: (index, device) => {
			settingsDevices.addDevice(device)
			device.modbusTcpId = modbusTcpServices.addDevice(device)
		}
		onObjectRemoved: (index, device) => {
			settingsDevices.removeDevice(device)
			modbusTcpServices.setInactive(device.modbusTcpId)
		}
	}
}
