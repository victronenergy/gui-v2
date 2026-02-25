/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	quantityModel: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject { object: statusCode; key: "statusText" }
		QuantityObject { object: statusCode.valid ? power : null; unit: VenusOS.Units_Watt }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/PageGenset.qml",
				{ bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: statusCode
		readonly property string statusText: valid
				? Global.acInputs.gensetStatusCodeToText(value)
				: CommonWords.not_connected
		uid: root.device.serviceUid + "/StatusCode"
	}

	VeQuickItem {
		id: power
		uid: root.device.serviceUid + "/Ac/Power"
	}
}
