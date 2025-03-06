/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml
import Victron.VenusOS

BaseDevice {
	id: root

	readonly property VeQuickItem _deviceInstance: VeQuickItem {
		uid: root.serviceUid ? root.serviceUid + "/DeviceInstance" : ""
	}

	readonly property VeQuickItem _customName: VeQuickItem {
		uid: root.serviceUid ? root.serviceUid + "/CustomName" : ""
		// When some devices (eg. BMSes), are turned off, the custom name value changes to 'undefined'
		// before they become invalid. See https://github.com/victronenergy/gui-v2/issues/1705.
		// Setting 'invalidate' to false retains the last valid value
		invalidate: false
	}

	readonly property VeQuickItem _productId: VeQuickItem {
		uid: root.serviceUid ? root.serviceUid + "/ProductId" : ""
	}

	readonly property VeQuickItem _productName: VeQuickItem {
		uid: root.serviceUid ? root.serviceUid + "/ProductName" : ""
	}

	deviceInstance: _deviceInstance.valid ? _deviceInstance.value : -1
	productId: _productId.valid ? _productId.value : 0
	productName: _productName.value || ""
	customName: _customName.value || ""
	name: _customName.value || _productName.value || ""
}
