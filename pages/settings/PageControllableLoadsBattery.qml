/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property Device device

	GradientListView {
		model: VisibleItemModel {
			ListSpinBox {
				id: startingBatterySoc
				//% "Activate following loads when battery reaches"
				text: qsTrId("pagecontrollableloads_battery_activate_following_loads_when_battery_reaches")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/ReservationStartSoc"
				suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
				from: 0
				to: 100
				preferredVisible: dataItem.valid
			}

			PrimaryListLabel {
				//% "Below this SOC, battery charging can use all solar surplus power."
				text: qsTrId("pagecontrollableloads_battery_below_this_soc_batt_charging_can_use_all_solar_surplus_power")
				preferredVisible: startingBatterySoc.dataItem.valid
			}

			SettingsListHeader {
				//% "Advanced"
				text: qsTrId("pagecontrollableloads_battery_advanced")
			}

			ListSpinBox {
				//% "At or above <font color=\"%1\">%2%</font> SOC"
				text: qsTrId("pagecontrollableloads_battery_at_or_above_x_soc")
						.arg(Theme.color_font_secondary)
						.arg(startingBatterySoc.dataItem.value)
				textFormat: Text.RichText
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/ReservationBasePower"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				preferredVisible: dataItem.valid
			}

			ListSpinBox {
				//% "At %1% SOC"
				text: qsTrId("pagecontrollableloads_battery_at_x_soc").arg(100)
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/ReservationEndPower"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				preferredVisible: dataItem.valid
			}

			PrimaryListLabel {
				//% "From the configured SOC to %1%, the power reserved for battery charging is reduced gradually, making more power available for loads."
				text: qsTrId("pagecontrollableloads_battery_from_configured_soc_to_100_percent").arg(100)
				preferredVisible: startingBatterySoc.dataItem.valid
			}
		}
	}
}
