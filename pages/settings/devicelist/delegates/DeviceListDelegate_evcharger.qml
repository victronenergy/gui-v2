/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	readonly property bool _showPower: !mode.isValid || status.value === VenusOS.Evcs_Status_Charging
	readonly property bool _showStatus: !_showPower && status.isValid

	quantityModel: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject { object: mode.isValid ? mode : null; key: "modeText" }
		QuantityObject { object: root._showPower ? power : null; unit: VenusOS.Units_Watt }
		QuantityObject { object: root._showStatus ? status : null; key: "statusText" }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/evcs/EvChargerPage.qml", { bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: mode
		readonly property string modeText: Global.evChargers.chargerModeToText(value)
		uid: root.device.serviceUid + "/Mode"
	}

	VeQuickItem {
		id: status
		readonly property string statusText: Global.evChargers.chargerStatusToText(value)
		uid: root.device.serviceUid + "/Status"
	}

	VeQuickItem {
		id: power
		uid: root.device.serviceUid + "/Ac/Power"
	}
}
