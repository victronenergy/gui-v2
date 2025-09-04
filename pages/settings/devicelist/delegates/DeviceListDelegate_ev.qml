/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	// Show enhanced info: SOC + charging state or location status
	secondaryText: {
		const socText = soc.valid ? Math.round(soc.value) + "%" : "--"

		if (chargingState.valid) {
			let stateText = ""
			switch (chargingState.value) {
			case 0:
				//% "Not charging"
				stateText = qsTrId("ev_charging_state_not_charging")
				break
			case 1:
				//% "Low power mode"
				stateText = qsTrId("ev_charging_state_low_power")
				break
			case 3:
				//% "Charging"
				stateText = qsTrId("ev_charging_state_charging")
				break
			case 244:
				//% "Sustain"
				stateText = qsTrId("ev_charging_state_sustain")
				break
			case 245:
				//% "Wake up"
				stateText = qsTrId("ev_charging_state_wake_up")
				break
			case 256:
				//% "Discharging"
				stateText = qsTrId("ev_charging_state_discharging")
				break
			case 259:
				//% "Scheduled charging"
				stateText = qsTrId("ev_charging_state_scheduled_charging")
				break
			default:
				stateText = ""
			}

			if (stateText !== "") {
				return socText + " | " + stateText
			}
		}

		// Fallback to location status if no charging state
		if (atSite.valid) {
			//% "Away"
			const locationText = atSite.value === 1 ? "At site" : qsTrId("ev_away")
			return socText + " | " + locationText
		}

		return socText
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/ev/EvPage.qml", { bindPrefix: root.device.serviceUid })
	}

	VeQuickItem {
		id: soc
		uid: root.device.serviceUid + "/Soc"
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
