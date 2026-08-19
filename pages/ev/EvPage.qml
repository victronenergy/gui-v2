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

	VeQuickItem {
		id: nrOfPhasesItem
		uid: root.bindPrefix + "/Ac/NrOfPhases"
	}
	VeQuickItem {
		id: batteryTemperatureItem
		uid: root.bindPrefix + "/BatteryTemperature"
	}
	VeQuickItem {
		id: odometerItem
		uid: root.bindPrefix + "/Odometer"
	}
	VeQuickItem {
		id: evContactItem
		uid: root.bindPrefix + "/LastUpdated/EvContact"
	}
	VeQuickItem {
		id: powerItem
		uid: root.bindPrefix + "/Ac/Power"
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

	function _systemDistanceUnit() {
		switch (Global.systemSettings.speedUnit) {
		case VenusOS.Units_Speed_KilometresPerHour:
			return VenusOS.Units_Kilometre
		case VenusOS.Units_Speed_MetresPerSecond:
			return VenusOS.Units_Metre
		case VenusOS.Units_Speed_Knots:
			return VenusOS.Units_Nautical_Mile
		case VenusOS.Units_Speed_MilesPerHour:
			return VenusOS.Units_Mile
		default:
			return VenusOS.Units_Metre
		}
	}

	settingsModel: DelegateComponentModel {
		DelegateComponent {
			ListQuantity {
				text: CommonWords.state_of_charge
				dataItem.uid: root.bindPrefix + "/Soc"
				unit: VenusOS.Units_Percentage
			}
		}

		DelegateComponent {
			ListQuantity {
				//% "Target state of charge"
				text: qsTrId("ev_target_soc")
				dataItem.uid: root.bindPrefix + "/TargetSoc"
				unit: VenusOS.Units_Percentage
			}
		}

		DelegateComponent {
			ListQuantity {
				//% "Range"
				text: qsTrId("ev_range")
				dataItem.uid: root.bindPrefix + "/RangeToGo"
				dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Kilometre)
				dataItem.displayUnit: Units.unitToVeUnit(root._systemDistanceUnit())
				unit: root._systemDistanceUnit()
				formatHints: Units.NoScaling
			}
		}

		DelegateComponent {
			ListQuantity {
				//% "Battery capacity"
				text: qsTrId("ev_battery_capacity")
				dataItem.uid: root.bindPrefix + "/BatteryCapacity"
				unit: VenusOS.Units_Energy_KiloWattHour
			}
		}

		DelegateComponent {
			preferredVisible: powerItem.valid && chargingState.valid && (chargingState.value === 3 || chargingState.value === 256 || chargingState.value === 259)
			ListQuantity {
				//% "Power"
				text: qsTrId("ev_power")
				dataItem.uid: root.bindPrefix + "/Ac/Power"
				unit: VenusOS.Units_Watt
								 (chargingState.value === 3 || chargingState.value === 256 || chargingState.value === 259)
			}
		}

		DelegateComponent {
			ListText {
				//% "Charging state"
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
		}

		DelegateComponent {
			ListText {
				//% "At site"
				text: qsTrId("ev_at_site")
				secondaryText: dataItem.valid ? (dataItem.value === 1 ? CommonWords.yes : CommonWords.no) : "--"
				dataItem.uid: root.bindPrefix + "/AtSite"
			}
		}

		DelegateComponent {
			preferredVisible: evContactItem.valid
			ListText {
				//% "Last contact"
				text: qsTrId("ev_last_contact")
				secondaryText: dataItem.valid ? Utils.formatTimestamp(new Date(dataItem.value * 1000), ClockTime.dateTime) : ""
				dataItem.uid: root.bindPrefix + "/LastUpdated/EvContact"
			}
		}

		DelegateComponent {
			ListText {
				//% "VIN"
				text: qsTrId("ev_vin")
				secondaryText: dataItem.valid ? dataItem.value : "--"
				dataItem.uid: root.bindPrefix + "/VIN"
			}
		}

		DelegateComponent {
			preferredVisible: odometerItem.valid
			ListQuantity {
				//% "Odometer"
				text: qsTrId("ev_odometer")
				dataItem.uid: root.bindPrefix + "/Odometer"
				dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Kilometre)
				dataItem.displayUnit: Units.unitToVeUnit(root._systemDistanceUnit())
				unit: root._systemDistanceUnit()
				formatHints: Units.NoScaling
			}
		}

		DelegateComponent {
			preferredVisible: latitude.valid && longitude.valid
			ListText {
				//% "Position"
				text: qsTrId("ev_position")
				secondaryText: latitude.valid && longitude.valid
						? "%1, %2"
							.arg(Global.systemSettings.formatLatitude(latitude.value))
							.arg(Global.systemSettings.formatLongitude(longitude.value))
						: "--"
			}
		}

		DelegateComponent {
			preferredVisible: batteryTemperatureItem.valid
			ListTemperature {
				text: CommonWords.battery_temperature
				dataItem.uid: root.bindPrefix + "/BatteryTemperature"
			}
		}

		DelegateComponent {
			preferredVisible: nrOfPhasesItem.valid
			ListText {
				//% "Number of phases"
				text: qsTrId("ev_nr_phases")
				secondaryText: dataItem.valid ? dataItem.value.toString() : "--"
				dataItem.uid: root.bindPrefix + "/Ac/NrOfPhases"
			}
		}
	}
}
