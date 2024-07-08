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
	}

	readonly property VeQuickItem _productId: VeQuickItem {
		uid: root.serviceUid ? root.serviceUid + "/ProductId" : ""
	}

	readonly property VeQuickItem _productName: VeQuickItem {
		uid: root.serviceUid ? root.serviceUid + "/ProductName" : ""
	}

	deviceInstance: _deviceInstance.isValid ? _deviceInstance.value : -1
	productId: _productId.isValid ? _productId.value : 0
	productName: _productName.value || ""
	customName: _customName.value || ""
	name: _customName.value || _productName.value || ""
	description: name
}
