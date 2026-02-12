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
	quantityModel: QuantityObjectModel {
		QuantityObject { object: state; key: "textValue"; unit: VenusOS.Units_None }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/PageSwitch.qml", {
			serviceUid: root.device.serviceUid
		})
	}

	VeQuickItem {
		id: state

		readonly property string textValue: VenusOS.switch_deviceStateToText(value)

		uid: root.device.serviceUid + "/State"
	}
}
