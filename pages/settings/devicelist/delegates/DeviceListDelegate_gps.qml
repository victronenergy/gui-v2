/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	text: productName.valid ? productName.value : "--"

	onClicked: Global.pageManager.pushPage(pageGps)

	VeQuickItem {
		id: productName
		uid: root.device.serviceUid + "/ProductName"
	}

	Component { id: pageGps; PageGps { title: root.text; bindPrefix: root.device.serviceUid } }
}
