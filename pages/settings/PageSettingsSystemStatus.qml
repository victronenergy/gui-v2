/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

Page {
	id: root

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				//% "Synchronize VE.Bus SOC with battery"
				text: qsTrId("settings_system_status_sync_vebus_soc_with_battery")
				dataSource: Global.system.serviceUid + "/Control/VebusSoc"
				secondaryText: CommonWords.onOrOff(dataValue)
			}

			ListTextItem {
				//% "Use solar charger current to improve VE.Bus SOC"
				text: qsTrId("settings_system_status_solar_charger_vebus")
				dataSource: Global.system.serviceUid + "/Control/ExtraBatteryCurrent"
				secondaryText: CommonWords.onOrOff(dataValue)
			}

			ListTextItem {
				//% "Solar charger voltage control"
				text: qsTrId("settings_system_status_solar_charger_voltage_control")
				dataSource: Global.system.serviceUid + "/Control/SolarChargeVoltage"
				secondaryText: CommonWords.onOrOff(dataValue)
			}

			ListTextItem {
				//% "Solar charger current control"
				text: qsTrId("settings_system_status_solar_charger_current_control")
				dataSource: Global.system.serviceUid + "/Control/SolarChargeCurrent"
				secondaryText: CommonWords.onOrOff(dataValue)
			}

			ListTextItem {
				//% "BMS control"
				text: qsTrId("settings_system_status_bms_params")
				dataSource: Global.system.serviceUid + "/Control/BmsParameters"
				secondaryText: CommonWords.onOrOff(dataValue)
			}
		}
	}
}
