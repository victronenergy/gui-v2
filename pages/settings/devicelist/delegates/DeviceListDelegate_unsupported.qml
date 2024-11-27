/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	//: Device is not supported
	//% "Unsupported"
	secondaryText: qsTrId("devicelist_unsupported")

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/PageUnsupportedDevice.qml",
				{ "title": text, bindPrefix : root.device.serviceUid })
	}
}
