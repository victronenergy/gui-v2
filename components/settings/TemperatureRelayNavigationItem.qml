/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

SettingsListNavigationItem {
	id: root

	property string bindPrefix
	property string sensorId

	readonly property string tempRelayPrefix: "com.victronenergy.temprelay/Sensor/" + sensorId
	readonly property string settingsBindPrefix: "com.victronenergy.settings/Settings/TempSensorRelay/" + sensorId

	function temperatureTypeText(value) {
		switch (value) {
		case VenusOS.Temperature_DeviceType_Battery:
			//% "Battery"
			return qsTrId("settings_relay_device_battery")
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
		if (customName.valid && customName.value !== "") {
			return customName.value
		}
		const inputNumber = devInstance.valid ? devInstance.value : ""

		if (temperatureType.valid) {
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
			//% "Temperature sensor"
			return qsTrId("settings_relay_title_default")
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
		if (c0.valid && c0.value > -1) {
			//: %1 = Relay 1 activation value, %2 = Relay 1 deactivation value
			//% "C1: %1, %2"
			summary.push(qsTrId("settings_relay_c0_desc").arg(c0Set.value || "--").arg(c0Clear.value || "--"))
		}
		if (c1.valid && c1.value > -1) {
			//: %1 = Relay 2 activation value, %2 = Relay 2 deactivation value
			//% "C2: %1, %2"
			summary.push(qsTrId("settings_relay_c1_desc").arg(c1Set.value || "--").arg(c1Clear.value || "--"))
		}
		return summary.length > 1 ? summary.join(" | ") : summary[0]
	}

	text: getTitle()
	secondaryText: getSummary()

	DataPoint {
		id: devInstance
		source: bindPrefix + "/DeviceInstance"
	}

	DataPoint {
		id: temperatureType
		source: bindPrefix + "/TemperatureType"
	}

	DataPoint {
		id: customName
		source: bindPrefix + "/CustomName"
	}

	DataPoint {
		id: functionEnabled
		source: tempRelayPrefix + "/Enabled"
	}

	DataPoint {
		id: c0Relay
		source: settingsBindPrefix + "/0/Relay"
	}

	DataPoint {
		id: c1Relay
		source: settingsBindPrefix + "/1/Relay"
	}

	DataPoint {
		id: c0Set
		source: settingsBindPrefix + "/0/SetValue"
	}

	DataPoint {
		id: c1Set
		source: settingsBindPrefix + "/1/SetValue"
	}

	DataPoint {
		id: c0Clear
		source: settingsBindPrefix + "/0/ClearValue"
	}

	DataPoint {
		id: c1Clear
		source: settingsBindPrefix + "/1/ClearValue"
	}
}
