/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

ListNavigationItem {
	id: root

	property string bindPrefix
	property string sensorId

	readonly property string tempRelayPrefix: BackendConnection.serviceUidForType("temprelay") + "/Sensor/" + sensorId
	readonly property string settingsBindPrefix: Global.systemSettings.serviceUid + "/Settings/TempSensorRelay/" + sensorId

	function temperatureTypeText(value) {
		switch (value) {
		case VenusOS.Temperature_DeviceType_Battery:
			return CommonWords.battery
		case VenusOS.Temperature_DeviceType_Fridge:
			//% "Fridge"
			return qsTrId("settings_relay_device_fridge")
		case VenusOS.Temperature_DeviceType_Generic:
			//% "Generic"
			return qsTrId("settings_relay_device_generic")
		default:
			//% "Unknown"
			return qsTrId("settings_relay_device_unknown")
		}
	}

	function getTitle() {
		if (customName.isValid && customName.value !== "") {
			return customName.value
		}
		const inputNumber = devInstance.isValid ? devInstance.value : ""

		if (temperatureType.isValid) {
			if (inputNumber === "") {
				//: %1 = temperature sensor type
				//% "%1 temperature sensor"
				return qsTrId("settings_relay_title_type_only").arg(temperatureTypeText(temperatureType.value))
			} else {
				//: %1 = temperature sensor type, %2 = input number of the sensor
				//% "%1 temperature sensor (%2)"
				return qsTrId("settings_relay_title_type_and_number").arg(temperatureTypeText(temperatureType.value), inputNumber)
			}
		}

		if (inputNumber === "") {
			return CommonWords.temperature_sensor
		} else {
			//: %1 = input number of the sensor
			//% "Temperature sensor (%1)"
			return qsTrId("settings_relay_title_number_only").arg(inputNumber)
		}
	}

	function getSummary() {
		let summary = []
		const c0 = c0Relay
		const c1 = c1Relay

		if (functionEnabled.value === 0 || (c0.value === -1 && c1.value === -1)) {
			//% "No actions"
			return qsTrId("settings_relay_no_actions")
		}
		if (c0.isValid && c0.value > -1) {
			//: %1 = Relay 1 activation value, %2 = Relay 1 deactivation value
			//% "C1: %1, %2"
			summary.push(qsTrId("settings_relay_c0_desc").arg(c0Set.value || "--").arg(c0Clear.value || "--"))
		}
		if (c1.isValid && c1.value > -1) {
			//: %1 = Relay 2 activation value, %2 = Relay 2 deactivation value
			//% "C2: %1, %2"
			summary.push(qsTrId("settings_relay_c1_desc").arg(c1Set.value || "--").arg(c1Clear.value || "--"))
		}
		return summary.length > 1 ? summary.join(" | ") : summary[0]
	}

	text: getTitle()
	secondaryText: getSummary()

	VeQuickItem {
		id: devInstance
		uid: bindPrefix + "/DeviceInstance"
	}

	VeQuickItem {
		id: temperatureType
		uid: bindPrefix + "/TemperatureType"
	}

	VeQuickItem {
		id: customName
		uid: bindPrefix + "/CustomName"
	}

	VeQuickItem {
		id: functionEnabled
		uid: tempRelayPrefix + "/Enabled"
	}

	VeQuickItem {
		id: c0Relay
		uid: settingsBindPrefix + "/0/Relay"
	}

	VeQuickItem {
		id: c1Relay
		uid: settingsBindPrefix + "/1/Relay"
	}

	VeQuickItem {
		id: c0Set
		uid: settingsBindPrefix + "/0/SetValue"
	}

	VeQuickItem {
		id: c1Set
		uid: settingsBindPrefix + "/1/SetValue"
	}

	VeQuickItem {
		id: c0Clear
		uid: settingsBindPrefix + "/0/ClearValue"
	}

	VeQuickItem {
		id: c1Clear
		uid: settingsBindPrefix + "/1/ClearValue"
	}
}
