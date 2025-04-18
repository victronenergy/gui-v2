/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	text: root.device.customName || VenusOS.digitalInput_typeToText(type.value)
	secondaryText: VenusOS.digitalInput_stateToText(state.value)

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/PageDigitalInput.qml",
				{ bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: state
		uid: root.device.serviceUid + "/State"
	}

	VeQuickItem {
		id: type
		uid: root.device.serviceUid + "/Type"
	}
}
