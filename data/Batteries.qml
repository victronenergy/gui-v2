/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "batteries"
	}

	property var system: SystemBattery {}

	function addBattery(battery) {
		model.addDevice(battery)
	}

	function removeBattery(battery) {
		model.removeDevice(battery.serviceUid)
	}

	function reset() {
		model.clear()
	}

	function timeToGoText(battery, format) {
		if ((battery.timeToGo || 0) <= 0) {
			return ""
		}
		const text = Utils.secondsToString(battery.timeToGo)
		if (format === VenusOS.Battery_TimeToGo_LongFormat) {
			//: %1 = time remaining, e.g. '3h 2m'
			//% "%1 to go"
			return qsTrId("brief_battery_time_to_go").arg(text)
		} else {
			return text
		}
	}

	function batteryIcon(battery) {
		return isNaN(battery.power) || battery.power === 0 ? "qrc:/images/icon_battery_24.svg"
			: (battery.power > 0 ? "qrc:/images/icon_battery_charging_24.svg" : "qrc:/images/icon_battery_discharging_24.svg")
	}

	function batteryMode(battery) {
		return isNaN(battery.power) || battery.power === 0 ? VenusOS.Battery_Mode_Idle
			: (battery.power > 0 ? VenusOS.Battery_Mode_Charging : VenusOS.Battery_Mode_Discharging)
	}

	function modeToText(mode) {
		switch (mode) {
		case VenusOS.Battery_Mode_Idle:
			return CommonWords.idle
		case VenusOS.Battery_Mode_Charging:
			return CommonWords.charging
		case VenusOS.Battery_Mode_Discharging:
			return CommonWords.discharging
		default:
			return ""
		}
	}

	readonly property VeQuickItem _batteries: VeQuickItem {
		uid: Global.system.serviceUid + "/Batteries"
		onValueChanged: {
			let i
			if (!isValid) {
				root.model.deleteAllAndClear()
				return
			}
			// Value is a list of key-value pairs with info about each battery.
			const batteryUids = value.map((info) => BackendConnection.serviceUidFromName(info.id, info.instance))

			// Remove batteries from Global.batteries.model that are not in this list
			root.model.intersect(batteryUids)

			// Add new entries to Global.batteries.model
			for (i = 0; i < batteryUids.length; ++i) {
				if (root.model.indexOf(batteryUids[i]) < 0) {
					_batteryComponent.createObject(root, { serviceUid: batteryUids[i] })
				}
			}
		}
	}

	property Component _batteryComponent: Component {
		Battery {
			id: battery

			onValidChanged: {
				if (valid) {
					root.addBattery(battery)
				} else {
					root.removeBattery(battery.serviceUid)
					battery.destroy()
				}
			}
		}
	}

	Component.onCompleted: Global.batteries = root
}
