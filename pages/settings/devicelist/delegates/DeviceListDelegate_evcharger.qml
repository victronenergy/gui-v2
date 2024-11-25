/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	readonly property var _powerModel: [ { unit: VenusOS.Units_Watt, value: power.value } ]
	readonly property var _statusModel: [ { unit: VenusOS.Units_None, value: Global.evChargers.chargerStatusToText(status.value) } ]
	readonly property var _modeModel: [ { unit: VenusOS.Units_None, value: Global.evChargers.chargerModeToText(mode.value) } ]

	quantityModel: {
		let secondaryInfo = []
		if (!mode.isValid || status.value === VenusOS.Evcs_Status_Charging) {
			secondaryInfo = [ { unit: VenusOS.Units_Watt, value: power.value } ]
		} else if (status.isValid) {
			secondaryInfo = [ { unit: VenusOS.Units_None, value: Global.evChargers.chargerStatusToText(status.value) } ]
		}
		return mode.isValid ? _modeModel.concat(secondaryInfo) : secondaryInfo
	}

	onClicked: {
		const evCharger = sourceModel.deviceAt(sourceModel.indexOf(root.device.serviceUid))
		Global.pageManager.pushPage("/pages/evcs/EvChargerPage.qml", { evCharger : evCharger })
	}

	VeQuickItem {
		id: mode
		uid: root.device.serviceUid + "/Mode"
	}

	VeQuickItem {
		id: status
		uid: root.device.serviceUid + "/Status"
	}

	VeQuickItem {
		id: power
		uid: root.device.serviceUid + "/Ac/Power"
	}
}
