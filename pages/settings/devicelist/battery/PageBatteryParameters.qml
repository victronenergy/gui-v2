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
		model: VisibleItemModel {
			ListQuantity {
				//% "Charge Voltage Limit (CVL)"
				text: qsTrId("batteryparameters_charge_voltage_limit_cvl")
				dataItem.uid: root.bindPrefix + "/Info/MaxChargeVoltage"
				unit: VenusOS.Units_Volt_DC
			}

			ListQuantity {
				//% "Charge Current Limit (CCL)"
				text: qsTrId("batteryparameters_charge_current_limit_ccl")
				dataItem.uid: root.bindPrefix + "/Info/MaxChargeCurrent"
				unit: VenusOS.Units_Amp
			}

			ListQuantity {
				//% "Discharge Current Limit (DCL)"
				text: qsTrId("batteryparameters_discharge_current_limit_dcl")
				dataItem.uid: root.bindPrefix + "/Info/MaxDischargeCurrent"
				unit: VenusOS.Units_Amp
			}

			ListQuantity {
				//% "Low Voltage Disconnect (always ignored)"
				text: qsTrId("batteryparameters_low_voltage_disconnect_always_ignored")
				dataItem.uid: root.bindPrefix + "/Info/BatteryLowVoltage"
				preferredVisible: dataItem.valid
				showAccessLevel: VenusOS.User_AccessType_Service
				unit: VenusOS.Units_Volt_DC
			}

			ListText {
				//: Shows if the battery requests charging: yes or no
				//% "Requests Charging"
				text: qsTrId("batteryparameters_charge_request")
				dataItem.uid: root.bindPrefix + "/Info/ChargeRequest"
				preferredVisible: dataItem.valid
				secondaryText: CommonWords.yesOrNo(dataItem.value)
			}
		}
	}
}
