/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	SettingsListView {
		model: ObjectModel {
			SettingsListTextItem {
				//% "Synchronize VE.Bus SOC with battery"
				text: qsTrId("settings_system_status_sync_vebus_soc_with_battery")
				source: "com.victronenergy.system/Control/VebusSoc"
				secondaryText: Utils.qsTrIdOnOff(dataPoint.value)
			}

			SettingsListTextItem {
				//% "Use solar charger current to improve VE.Bus SOC"
				text: qsTrId("settings_system_status_solar_charger_vebus")
				source: "com.victronenergy.system/Control/ExtraBatteryCurrent"
				secondaryText: Utils.qsTrIdOnOff(dataPoint.value)
			}

			SettingsListTextItem {
				//% "Solar charger voltage control"
				text: qsTrId("settings_system_status_solar_charger_voltage_control")
				source: "com.victronenergy.system/Control/SolarChargeVoltage"
				secondaryText: Utils.qsTrIdOnOff(dataPoint.value)
			}

			SettingsListTextItem {
				//% "Solar charger current control"
				text: qsTrId("settings_system_status_solar_charger_current_control")
				source: "com.victronenergy.system/Control/SolarChargeCurrent"
				secondaryText: Utils.qsTrIdOnOff(dataPoint.value)
			}

			SettingsListTextItem {
				//% "BMS control"
				text: qsTrId("settings_system_status_bms_params")
				source: "com.victronenergy.system/Control/BmsParameters"
				secondaryText: Utils.qsTrIdOnOff(dataPoint.value)
			}
		}
	}
}
