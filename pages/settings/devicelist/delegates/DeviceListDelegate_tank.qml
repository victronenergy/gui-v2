/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	readonly property string statusText: level.valid ? "" : (status.valid ? Services.tanks.statusToText(status.value) : "")

	quantityModel: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject { object: root; key: root.statusText ? "statusText" : ""; unit: VenusOS.Units_None }
		QuantityObject { object: temperature; unit: Services.settings.temperatureUnit }
		QuantityObject { object: remaining; unit: Services.settings.volumeUnit }
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
		displayUnit: Units.unitToVeUnit(Services.settings.temperatureUnit)
	}

	VeQuickItem {
		id: level
		uid: root.device.serviceUid + "/Level"
	}

	VeQuickItem {
		id: remaining
		uid: root.device.serviceUid + "/Remaining"
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Volume_CubicMetre)
		displayUnit: Units.unitToVeUnit(Services.settings.volumeUnit)
	}

	VeQuickItem {
		id: status
		uid: root.device.serviceUid + "/Status"
	}
}
