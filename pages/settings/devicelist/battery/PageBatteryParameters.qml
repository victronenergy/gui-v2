/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListQuantityItem {
				//% "Charge Voltage Limit (CVL)"
				text: qsTrId("batteryparameters_charge_voltage_limit_cvl")
				dataSource: root.bindPrefix + "/Info/MaxChargeVoltage"
				unit: Enums.Units_Volt
			}

			ListQuantityItem {
				//% "Charge Current Limit (CCL)"
				text: qsTrId("batteryparameters_charge_current_limit_ccl")
				dataSource: root.bindPrefix + "/Info/MaxChargeCurrent"
				unit: Enums.Units_Amp
			}

			ListQuantityItem {
				//% "Discharge Current Limit (DCL)"
				text: qsTrId("batteryparameters_discharge_current_limit_dcl")
				dataSource: root.bindPrefix + "/Info/MaxDischargeCurrent"
				unit: Enums.Units_Amp
			}

			ListQuantityItem {
				//% "Low Voltage Disconnect (always ignored)"
				text: qsTrId("batteryparameters_low_voltage_disconnect_always_ignored")
				dataSource: root.bindPrefix + "/Info/BatteryLowVoltage"
				showAccessLevel: Enums.User_AccessType_Service
				unit: Enums.Units_Volt
			}
		}
	}
}
