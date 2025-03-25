/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	secondaryText: VenusOS.switch_deviceStateToText(state.value)

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/PageSwitch.qml",
				{ device:root.device })
	}

	VeQuickItem {
		id: state
		uid: root.device.serviceUid + "/State"
	}
}
