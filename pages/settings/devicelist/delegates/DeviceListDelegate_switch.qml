/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	text: {
		if (device.customName) {
			return device.customName
		} else if (device.deviceInstance >= 0 && device.productName) {
			return `${device.productName} (${device.deviceInstance})`
		} else {
			return ""
		}
	}

	secondaryText: VenusOS.switch_deviceStateToText(state.value)

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/PageSwitch.qml", {
			serviceUid: root.device.serviceUid,
			title: Qt.binding(function() { return root.text })
		})
	}

	VeQuickItem {
		id: state
		uid: root.device.serviceUid + "/State"
	}
}
