/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	readonly property var _allModel: [
		{ unit: Global.systemSettings.temperatureUnit, value: temperature.value },
		{ unit: Global.systemSettings.volumeUnit, value: remaining.value },
		{ unit: VenusOS.Units_Percentage, value: level.value }
	]

	readonly property var _remainingAndLevelModel: [
		{ unit: Global.systemSettings.volumeUnit, value: remaining.value },
		{ unit: VenusOS.Units_Percentage, value: level.value }
	]

	readonly property var _temperatureAndLevelModel: [
		{ unit: Global.systemSettings.temperatureUnit, value: temperature.value },
		{ unit: VenusOS.Units_Percentage, value: level.value },
	]

	readonly property var _levelModel: [
		{ unit: VenusOS.Units_Percentage, value: level.value },
	]

	readonly property var _remainingModel: [
		{ unit: Global.systemSettings.volumeUnit, value: remaining.value }
	]

	secondaryText: level.isValid ? "" : (status.isValid ? Global.tanks.statusToText(status.value) : "--")
	quantityModel: level.isValid && temperature.isValid && remaining.isValid ? _allModel
			: level.isValid && remaining.isValid ? _remainingAndLevelModel
			: level.isValid && temperature.isValid ? _temperatureAndLevelModel
			: level.isValid ? _levelModel
			: remaining.isValid ? _remainingModel
			: null

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankSensor.qml",
				{ bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: temperature
		uid: root.device.serviceUid + "/Temperature"
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}

	VeQuickItem {
		id: level
		uid: root.device.serviceUid + "/Level"
	}

	VeQuickItem {
		id: remaining
		uid: root.device.serviceUid + "/Remaining"
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Volume_CubicMeter)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.volumeUnit)
	}

	VeQuickItem {
		id: status
		uid: root.device.serviceUid + "/Status"
	}
}
