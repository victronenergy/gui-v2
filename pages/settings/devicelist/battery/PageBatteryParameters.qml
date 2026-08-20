/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: chargeRequestItem
		uid: root.bindPrefix + "/Info/ChargeRequest"
	}
	VeQuickItem {
		id: batteryLowVoltageItem
		uid: root.bindPrefix + "/Info/BatteryLowVoltage"
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListQuantity {
					//% "Charge Voltage Limit (CVL)"
					text: qsTrId("batteryparameters_charge_voltage_limit_cvl")
					dataItem.uid: root.bindPrefix + "/Info/MaxChargeVoltage"
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				ListQuantity {
					//% "Charge Current Limit (CCL)"
					text: qsTrId("batteryparameters_charge_current_limit_ccl")
					dataItem.uid: root.bindPrefix + "/Info/MaxChargeCurrent"
					unit: VenusOS.Units_Amp
				}
			}

			DelegateComponent {
				ListQuantity {
					//% "Discharge Current Limit (DCL)"
					text: qsTrId("batteryparameters_discharge_current_limit_dcl")
					dataItem.uid: root.bindPrefix + "/Info/MaxDischargeCurrent"
					unit: VenusOS.Units_Amp
				}
			}

			DelegateComponent {
				preferredVisible: batteryLowVoltageItem.valid
				ListQuantity {
					//% "Low Voltage Disconnect (always ignored)"
					text: qsTrId("batteryparameters_low_voltage_disconnect_always_ignored")
					dataItem.uid: root.bindPrefix + "/Info/BatteryLowVoltage"
					showAccessLevel: VenusOS.User_AccessType_Service
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				preferredVisible: chargeRequestItem.valid
				ListText {
					//: Shows if the battery requests charging: yes or no
					//% "Requests Charging"
					text: qsTrId("batteryparameters_charge_request")
					dataItem.uid: root.bindPrefix + "/Info/ChargeRequest"
					secondaryText: CommonWords.yesOrNo(dataItem.value)
				}
			}
		}
	}
}
