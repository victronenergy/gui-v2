/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				//% "Synchronize VE.Bus SOC with battery"
				text: qsTrId("settings_system_status_sync_vebus_soc_with_battery")
				dataSource: "com.victronenergy.system/Control/VebusSoc"
				secondaryText: CommonWords.onOrOff(dataValue)
			}

			ListTextItem {
				//% "Use solar charger current to improve VE.Bus SOC"
				text: qsTrId("settings_system_status_solar_charger_vebus")
				dataSource: "com.victronenergy.system/Control/ExtraBatteryCurrent"
				secondaryText: CommonWords.onOrOff(dataValue)
			}

			ListTextItem {
				//% "Solar charger voltage control"
				text: qsTrId("settings_system_status_solar_charger_voltage_control")
				dataSource: "com.victronenergy.system/Control/SolarChargeVoltage"
				secondaryText: CommonWords.onOrOff(dataValue)
			}

			ListTextItem {
				//% "Solar charger current control"
				text: qsTrId("settings_system_status_solar_charger_current_control")
				dataSource: "com.victronenergy.system/Control/SolarChargeCurrent"
				secondaryText: CommonWords.onOrOff(dataValue)
			}

			ListTextItem {
				//% "BMS control"
				text: qsTrId("settings_system_status_bms_params")
				dataSource: "com.victronenergy.system/Control/BmsParameters"
				secondaryText: CommonWords.onOrOff(dataValue)
			}
		}
	}
}
