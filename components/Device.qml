/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQml
import Victron.Veutil

QtObject {
	id: root

	property string serviceUid

	property string name: customName.value || productName.value || ""

	readonly property VeQuickItem deviceInstance: VeQuickItem {
		uid: root.serviceUid ? root.serviceUid + "/DeviceInstance" : ""
	}

	readonly property VeQuickItem customName: VeQuickItem {
		uid: root.serviceUid ? root.serviceUid + "/CustomName" : ""
	}

	readonly property VeQuickItem productName: VeQuickItem {
		uid: root.serviceUid ? root.serviceUid + "/ProductName" : ""
	}
}
