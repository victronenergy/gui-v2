/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	text: root.device.customName
		  || (root.device.deviceInstance >= 0 && root.device.productName ? `${root.device.productName} ${root.device.deviceInstance}` : "")
		  || ""

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
