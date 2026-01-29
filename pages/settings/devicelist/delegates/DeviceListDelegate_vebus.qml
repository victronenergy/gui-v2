/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	quantityModel: QuantityObjectModel {
		QuantityObject { object: state; key: "textValue"; unit: VenusOS.Units_None }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/vebusdevice/PageVeBus.qml", { bindPrefix: root.device.serviceUid })
	}

	VeQuickItem {
		id: state

		readonly property string textValue: Global.system.systemStateToText(value)

		uid: root.device.serviceUid + "/State"
	}
}
