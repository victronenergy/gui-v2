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

			ListTextItem {
				text: "Charge Mode"
				dataItem.uid: root.bindPrefix + "/Info/ChargeMode"
			}

			ListItem {
				text: "Charge Mode Debug"

				bottomContentChildren: [
					ListLabel {
						topPadding: 0
						bottomPadding: 0
						color: Theme.color_font_secondary
						text: chargeModeDebug.value
						horizontalAlignment: Text.AlignHCenter
					}
				]

				VeQuickItem {
					id: chargeModeDebug
					uid: root.bindPrefix + "/Info/ChargeModeDebug"
				}
			}

			ListQuantityItem {
				//% "Charge Voltage Limit (CVL)"
				text: qsTrId("batteryparameters_charge_voltage_limit_cvl")
				dataItem.uid: root.bindPrefix + "/Info/MaxChargeVoltage"
				unit: VenusOS.Units_Volt
			}

			ListTextItem {
				text: "Charge Limitation"
				dataItem.uid: root.bindPrefix + "/Info/ChargeLimitation"
			}

			ListQuantityItem {
				//% "Charge Current Limit (CCL)"
				text: qsTrId("batteryparameters_charge_current_limit_ccl")
				dataItem.uid: root.bindPrefix + "/Info/MaxChargeCurrent"
				unit: VenusOS.Units_Amp
			}

			ListTextItem {
				text: "Discharge Limitation"
				dataItem.uid: root.bindPrefix + "/Info/DischargeLimitation"
			}

			ListQuantityItem {
				//% "Discharge Current Limit (DCL)"
				text: qsTrId("batteryparameters_discharge_current_limit_dcl")
				dataItem.uid: root.bindPrefix + "/Info/MaxDischargeCurrent"
				unit: VenusOS.Units_Amp
			}

			ListQuantityItem {
				//% "Low Voltage Disconnect (always ignored)"
				text: qsTrId("batteryparameters_low_voltage_disconnect_always_ignored")
				dataItem.uid: root.bindPrefix + "/Info/BatteryLowVoltage"
				showAccessLevel: VenusOS.User_AccessType_Service
				unit: VenusOS.Units_Volt
			}
		}
	}
}
