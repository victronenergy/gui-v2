/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	text: productName.valid ? productName.value : "--"

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/PageGps.qml",
									{"title": text, bindPrefix: root.device.serviceUid })
	}

	VeQuickItem {
		id: productName
		uid: root.device.serviceUid + "/ProductName"
	}
}
