/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	secondaryText: statusCode.isValid ? "" : CommonWords.not_connected
	quantityModel: statusCode.isValid
		? [
			  { unit: VenusOS.Units_None, value: Global.acInputs.gensetStatusCodeToText(statusCode.value) },
			  { value: power.value, unit: VenusOS.Units_Watt },
		  ]
		: null

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/PageGenset.qml",
				{ "title": text, bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: statusCode
		uid: root.device.serviceUid + "/StatusCode"
	}
}
