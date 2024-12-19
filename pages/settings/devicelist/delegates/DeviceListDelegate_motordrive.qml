/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	quantityModel: [
		{ unit: VenusOS.Units_RevolutionsPerMinute, value: motorRpm.value }
	]

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/PageMotorDrive.qml",
				{ bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: motorRpm
		uid: root.device.serviceUid + "/Motor/RPM"
	}
}
