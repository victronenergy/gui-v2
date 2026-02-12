/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	text: root.device.customName || VenusOS.digitalInput_typeToText(type.value)
	quantityModel: QuantityObjectModel {
		QuantityObject { object: state; key: "textValue"; unit: VenusOS.Units_None }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/PageDigitalInput.qml",
				{ bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: state

		readonly property string textValue: VenusOS.digitalInput_stateToText(value)

		uid: root.device.serviceUid + "/State"
	}

	VeQuickItem {
		id: type
		uid: root.device.serviceUid + "/Type"
	}
}
