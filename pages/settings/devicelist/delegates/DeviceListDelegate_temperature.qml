/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	readonly property var _temperatureAndHumidityModel: [
		{ unit: Global.systemSettings.temperatureUnit, value: temperature.value },
		{ unit: VenusOS.Units_Percentage, value: humidity.value },
	]

	readonly property var _temperatureModel: [
		{ unit: Global.systemSettings.temperatureUnit, value: temperature.value },
	]

	quantityModel: humidity.isValid ? _temperatureAndHumidityModel : _temperatureModel

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/temperature/PageTemperatureSensor.qml",
				{ "title": text, bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: temperature
		uid: root.device.serviceUid + "/Temperature"
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}

	VeQuickItem {
		id: humidity
		uid: root.device.serviceUid + "/Humidity"
	}
}
