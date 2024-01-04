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
				dataItem.uid: Global.system.serviceUid + "/Control/VebusSoc"
				secondaryText: CommonWords.onOrOff(dataItem.value)
			}

			ListTextItem {
				//% "Use solar charger current to improve VE.Bus SOC"
				text: qsTrId("settings_system_status_solar_charger_vebus")
				dataItem.uid: Global.system.serviceUid + "/Control/ExtraBatteryCurrent"
				secondaryText: CommonWords.onOrOff(dataItem.value)
			}

			ListTextItem {
				//% "Solar charger voltage control"
				text: qsTrId("settings_system_status_solar_charger_voltage_control")
				dataItem.uid: Global.system.serviceUid + "/Control/SolarChargeVoltage"
				secondaryText: CommonWords.onOrOff(dataItem.value)
			}

			ListTextItem {
				//% "Solar charger current control"
				text: qsTrId("settings_system_status_solar_charger_current_control")
				dataItem.uid: Global.system.serviceUid + "/Control/SolarChargeCurrent"
				secondaryText: CommonWords.onOrOff(dataItem.value)
			}

			ListTextItem {
				//% "BMS control"
				text: qsTrId("settings_system_status_bms_params")
				dataItem.uid: Global.system.serviceUid + "/Control/BmsParameters"
				secondaryText: CommonWords.onOrOff(dataItem.value)
			}
		}
	}
}
