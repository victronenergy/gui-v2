/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// A model of Device objects, generated from com.victronenergy.system/Batteries.
DeviceModel {
	id: root

	// The battery list is a list of JSON values like this:
	// [{'active_battery_service': 1,'current': 55,'id': com.victronenergy.battery.ttyO0,'instance': 256,'name': House battery,'power': 1337,'soc': 98.4,'state': 1,'timetogo': 38040,'voltage': 24.3}]
	// Only 'id', 'name' and 'active_battery_service' are guaranteed to be present for each battery.
	readonly property VeQuickItem _batteriesItem: VeQuickItem {
		uid: Global.system.serviceUid + "/Batteries"
		onValueChanged: {
			if (!valid) {
				root.deleteAllAndClear()
				return
			}
			const batteryList = value

			// Make a list of battery uids for identifying each battery in batteryList.
			let batteryUids = []
			let i
			for (i = 0; i < batteryList.length; ++i) {
				const serviceName = batteryList[i].id
				if (batteryList[i].instance === undefined) {
					// This is a not a real battery; there is an id number on the end of the service
					// name, like com.victronenergy.battery.ttyUSB1:1, and there is no device
					// 'instance'. So, use the service name as the uid, else if we use a dummy
					// instance, it might be the same as the instance of a real battery, and they
					// would have the same uids within the device model.
					// (Normally the service name couldn't be used as the uid, but since the JSON
					// provides all data to be shown in the battery list, the uid won't be used to
					// fetch any other data.)
					batteryUids.push(serviceName)
				} else {
					// This is a real battery, with a valid (device) instance.
					batteryUids.push(BackendConnection.serviceUidFromName(serviceName, batteryList[i].instance))
				}
			}

			// Remove batteries that are not in this list
			root.intersect(batteryUids)

			// Add new battery objects, or update existing ones in the list.
			for (i = 0; i < batteryList.length; ++i) {
				const batteryInfo = batteryList[i]
				const batteryUid = batteryUids[i]   // ok because batteryList.length === batteryUids.length
				let batteryObject
				const batteryIndex = root.indexOf(batteryUid)
				if (batteryIndex < 0) {
					batteryObject = _batteryComponent.createObject(root, {
						serviceUid: batteryUid,
						deviceInstance: batteryInfo.instance || 0,  // always provide an instance so that BaseDevice::valid, so device is added to model
						customName: batteryInfo.name || "",
					})
				} else {
					batteryObject = root.deviceAt(batteryIndex)
				}
				batteryObject.setValueIfValid("current", batteryInfo.current)
				batteryObject.setValueIfValid("power", batteryInfo.power)
				batteryObject.setValueIfValid("stateOfCharge", batteryInfo.soc)
				batteryObject.setValueIfValid("timeToGo", batteryInfo.timetogo)
				batteryObject.setValueIfValid("voltage", batteryInfo.voltage)
			}
		}
	}

	component Battery : BaseDevice {
		id: battery

		property real current: NaN
		property real power: NaN
		property real stateOfCharge: NaN
		property real temperature: NaN
		property int timeToGo: 0
		property real voltage: NaN
		readonly property int mode: VenusOS.battery_modeFromPower(power)

		function setValueIfValid(propertyName, value) {
			if (value !== undefined) {
				battery[propertyName] = value
			}
		}

		name: customName
	}

	readonly property Component _batteryComponent: Component {
		Battery {
		   id: battery

			onValidChanged: {
				if (valid) {
					root.addDevice(battery)
				} else {
					root.removeDevice(battery.serviceUid)
					battery.destroy()
				}
			}
		}
	}
}
