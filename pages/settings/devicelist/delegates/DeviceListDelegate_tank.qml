/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	secondaryText: level.valid ? "" : (status.valid ? Global.tanks.statusToText(status.value) : "--")
	quantityModel: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject { object: temperature; unit: Global.systemSettings.temperatureUnit }
		QuantityObject { object: remaining; unit: Global.systemSettings.volumeUnit }
		QuantityObject { object: level; unit: VenusOS.Units_Percentage }
	}

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
