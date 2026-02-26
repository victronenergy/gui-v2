/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	function _systemDistanceUnit() {
		switch (Global.systemSettings.speedUnit) {
		case VenusOS.Units_Speed_KilometresPerHour:
			return VenusOS.Units_Kilometre
		case VenusOS.Units_Speed_MetresPerSecond:
			return VenusOS.Units_Metre
		case VenusOS.Units_Speed_Knots:
			return VenusOS.Units_Nautical_Mile
		case VenusOS.Units_Speed_MilesPerHour:
			return VenusOS.Units_Mile
		default:
			return VenusOS.Units_Metre
		}
	}

	quantityModel: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject { object: soc; unit: VenusOS.Units_Percentage }
		QuantityObject { object: range; unit: root._systemDistanceUnit() }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/ev/EvPage.qml", {
			bindPrefix: root.device.serviceUid
		})
	}

	VeQuickItem {
		id: soc
		uid: root.device.serviceUid + "/Soc"
	}

	VeQuickItem {
		id: range

		uid: root.device.serviceUid + "/RangeToGo"
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Kilometre)
		displayUnit: Units.unitToVeUnit(root._systemDistanceUnit())
	}
}
