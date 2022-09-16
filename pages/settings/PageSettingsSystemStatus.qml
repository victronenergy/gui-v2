/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	function _valueToText(value) {
		if (value === 0) {
			//% "Off"
			return qsTrId("settings_system_status_off")
		} else if (value === 1) {
			//% "On"
			return qsTrId("settings_system_status_on")
		} else {
			//% "Unknown"
			return qsTrId("settings_system_status_unknown")
		}
	}

	SettingsListView {
		model: ObjectModel {
			SettingsListTextItem {
				//% "Synchronize VE.Bus SOC with battery"
				text: qsTrId("settings_system_status_sync_vebus_soc_with_battery")
				source: "com.victronenergy.system/Control/VebusSoc"
				secondaryText: root._valueToText(dataPoint.value)
			}

			SettingsListTextItem {
				//% "Use solar charger current to improve VE.Bus SOC"
				text: qsTrId("settings_system_status_solar_charger_vebus")
				source: "com.victronenergy.system/Control/ExtraBatteryCurrent"
				secondaryText: root._valueToText(dataPoint.value)
			}

			SettingsListTextItem {
				//% "Solar charger voltage control"
				text: qsTrId("settings_system_status_solar_charger_voltage_control")
				source: "com.victronenergy.system/Control/SolarChargeVoltage"
				secondaryText: root._valueToText(dataPoint.value)
			}

			SettingsListTextItem {
				//% "Solar charger current control"
				text: qsTrId("settings_system_status_solar_charger_current_control")
				source: "com.victronenergy.system/Control/SolarChargeCurrent"
				secondaryText: root._valueToText(dataPoint.value)
			}

			SettingsListTextItem {
				//% "BMS control"
				text: qsTrId("settings_system_status_bms_params")
				source: "com.victronenergy.system/Control/BmsParameters"
				secondaryText: root._valueToText(dataPoint.value)
			}
		}
	}
}
