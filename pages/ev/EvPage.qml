/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DevicePage {
	id: root

	required property string bindPrefix

	serviceUid: bindPrefix

	settingsModel: VisibleItemModel {
		ListText {
			//% "State of Charge"
			text: qsTrId("ev_soc")
			secondaryText: dataItem.valid ? Math.round(dataItem.value) + "%" : "--"
			dataItem.uid: root.bindPrefix + "/Soc"
		}

		ListText {
			//% "Target State of Charge"
			text: qsTrId("ev_target_soc")
			secondaryText: dataItem.valid ? Math.round(dataItem.value) + "%" : "--"
			dataItem.uid: root.bindPrefix + "/TargetSoc"
		}

		ListText {
			//% "Range"
			text: qsTrId("ev_range")
			secondaryText: dataItem.valid ? Math.round(dataItem.value) + " km" : "--"
			dataItem.uid: root.bindPrefix + "/RangeToGo"
		}

		ListText {
			//% "Battery Capacity"
			text: qsTrId("ev_battery_capacity")
			secondaryText: dataItem.valid ? dataItem.value + " kWh" : "--"
			dataItem.uid: root.bindPrefix + "/BatteryCapacity"
		}

		ListText {
			//% "Power"
			text: qsTrId("ev_power")
			secondaryText: dataItem.valid ? Math.round(dataItem.value) + " W" : "--"
			dataItem.uid: root.bindPrefix + "/Ac/Power"
			preferredVisible: dataItem.valid && chargingState.valid &&
							 (chargingState.value === 3 || chargingState.value === 256 || chargingState.value === 259)
		}

		ListText {
			//% "Charging State"
			text: qsTrId("ev_charging_state")
			secondaryText: {
				if (!dataItem.valid) return "--"
				switch (dataItem.value) {
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
					//% "Unknown"
					return qsTrId("ev_charging_state_unknown")
				}
			}
			dataItem.uid: root.bindPrefix + "/ChargingState"
		}

		ListText {
			//% "At Site"
			text: qsTrId("ev_at_site")
			secondaryText: dataItem.valid ? (dataItem.value === 1 ? CommonWords.yes : CommonWords.no) : "--"
			dataItem.uid: root.bindPrefix + "/AtSite"
		}

		ListText {
			//% "Last Contact"
			text: qsTrId("ev_last_contact")
			secondaryText: {
				if (!dataItem.valid) return "--"
				const now = new Date()
				const lastContact = new Date(dataItem.value * 1000)
				const diffMinutes = Math.floor((now - lastContact) / 60000)

				if (diffMinutes < 1) {
					//% "Just now"
					return qsTrId("ev_last_contact_just_now")
				} else if (diffMinutes < 60) {
					//% "%1 minutes ago"
					return qsTrId("ev_last_contact_minutes").arg(diffMinutes)
				} else {
					const diffHours = Math.floor(diffMinutes / 60)
					if (diffHours < 24) {
						//% "%1 hours ago"
						return qsTrId("ev_last_contact_hours").arg(diffHours)
					} else {
						const diffDays = Math.floor(diffHours / 24)
						//% "%1 days ago"
						return qsTrId("ev_last_contact_days").arg(diffDays)
					}
				}
			}
			dataItem.uid: root.bindPrefix + "/LastEvContact"
			preferredVisible: dataItem.valid
		}

		ListText {
			//% "VIN"
			text: qsTrId("ev_vin")
			secondaryText: dataItem.valid ? dataItem.value : "--"
			dataItem.uid: root.bindPrefix + "/VIN"
		}

		ListText {
			//% "Odometer"
			text: qsTrId("ev_odometer")
			secondaryText: dataItem.valid ? Math.round(dataItem.value) + " km" : "--"
			dataItem.uid: root.bindPrefix + "/Odometer"
			preferredVisible: dataItem.valid
		}

		ListText {
			//% "Position"
			text: qsTrId("ev_position")
			secondaryText: {
				if (latitude.valid && longitude.valid) {
					return latitude.value.toFixed(4) + ", " + longitude.value.toFixed(4)
				}
				return "--"
			}
			preferredVisible: latitude.valid && longitude.valid
		}

		ListText {
			//% "Battery Temperature"
			text: qsTrId("ev_battery_temperature")
			secondaryText: dataItem.valid ? Math.round(dataItem.value) + "°C" : "--"
			dataItem.uid: root.bindPrefix + "/BatteryTemperature"
			preferredVisible: dataItem.valid
		}

		ListText {
			//% "Number of Phases"
			text: qsTrId("ev_nr_phases")
			secondaryText: dataItem.valid ? dataItem.value.toString() : "--"
			dataItem.uid: root.bindPrefix + "/Ac/NrOfPhases"
			preferredVisible: dataItem.valid
		}
	}

	VeQuickItem {
		id: chargingState
		uid: root.bindPrefix + "/ChargingState"
	}

	VeQuickItem {
		id: latitude
		uid: root.bindPrefix + "/Position/Latitude"
	}

	VeQuickItem {
		id: longitude
		uid: root.bindPrefix + "/Position/Longitude"
	}
}
