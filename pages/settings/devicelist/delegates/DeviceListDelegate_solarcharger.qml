/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	readonly property var _errorModel: [
		//: %1 = error number
		//% "Error: #%1"
		{ unit: VenusOS.Units_None, value: qsTrId("devicelist_solarcharger_error").arg(errorCode.value) }
	]

	readonly property var _powerModel: [
		{ value: power.value, unit: VenusOS.Units_Watt }
	]

	quantityModel: errorCode.isValid && errorCode.value > 0 ? _errorModel : _powerModel

	onClicked: {
		Global.pageManager.pushPage("/pages/solar/SolarChargerPage.qml", { bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: power
		uid: root.device.serviceUid + "/Yield/Power"
	}

	VeQuickItem {
		id: errorCode
		uid: root.device.serviceUid + "/ErrorCode"
	}
}
