/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	quantityModel: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject { object: soc; unit: VenusOS.Units_Percentage }
		QuantityObject {
			object: chargingStateText;
			key: "stateText"
		}
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/ev/EvPage.qml", { bindPrefix: root.device.serviceUid })
	}

	VeQuickItem {
		id: soc
		uid: root.device.serviceUid + "/Soc"
	}

	QtObject {
		id: chargingStateText

		readonly property string stateText: {
			if (!chargingState.valid) {
				// Fallback to location status if no charging state
				if (atSite.valid) {
					//% "Away"
					return atSite.value === 1 ? "At site" : qsTrId("ev_away")
				}
				return ""
			}

			const intValue = parseInt(chargingState.value)
			switch (intValue) {
			case 0:
				//% "Not charging"
				return qsTrId("ev_charging_state_not_charging")
			case 1:
				//% "Low power mode"
				return qsTrId("ev_charging_state_low_power")
			case 3:
				//% "Charging"
				return qsTrId("ev_charging_state_charging")
			case 244:
				//% "Sustain"
				return qsTrId("ev_charging_state_sustain")
			case 245:
				//% "Wake up"
				return qsTrId("ev_charging_state_wake_up")
			case 256:
				//% "Discharging"
				return qsTrId("ev_charging_state_discharging")
			case 259:
				//% "Scheduled charging"
				return qsTrId("ev_charging_state_scheduled_charging")
			default:
				// Fallback to location status for unknown states
				if (atSite.valid) {
					//% "Away"
					return atSite.value === 1 ? "At site" : qsTrId("ev_away")
				}
				return ""
			}
		}
	}

	VeQuickItem {
		id: chargingState
		uid: root.device.serviceUid + "/ChargingState"
	}

	VeQuickItem {
		id: atSite
		uid: root.device.serviceUid + "/AtSite"
	}
}
