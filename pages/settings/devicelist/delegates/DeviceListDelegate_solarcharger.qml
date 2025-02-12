/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	readonly property bool _hasError: errorCode.isValid && errorCode.value > 0

	quantityModel: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject { object: root._hasError ? errorCode : null; key: "errorText" }
		QuantityObject { object: root._hasError ? null : power; unit: VenusOS.Units_Watt }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/solar/PageSolarCharger.qml", { bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: power
		uid: root.device.serviceUid + "/Yield/Power"
	}

	VeQuickItem {
		id: errorCode
		//: %1 = error number
		//% "Error: #%1"
		readonly property string errorText: qsTrId("devicelist_solarcharger_error").arg(value)
		uid: root.device.serviceUid + "/ErrorCode"
	}
}
