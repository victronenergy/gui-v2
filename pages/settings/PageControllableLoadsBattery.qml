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
			ListQuantityField {
				id: startingBatterySoc
				unit: VenusOS.Units_Percentage
				//% "Allow additional loads starting at a battery SOC of"
				text: qsTrId("pagecontrollableloads_battery_allow_additional_loads_starting_at_battery_soc")

				//% "Below this SOC, surplus power is used for battery charging as much as possible. From this SOC onward, additional loads may also use surplus power. They may still run earlier if PV production exceeds what the battery can absorb."
				caption: qsTrId("pagecontrollableloads_battery_below_this_soc")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/ReservationStartSoc"
			}

			SettingsListHeader {
				//% "Advanced"
				text: qsTrId("pagecontrollableloads_battery_advanced")
			}

			ListQuantityField {
				unit: VenusOS.Units_Watt
				//% "At <font color=\"%1\">%2%</font> SOC, reserve for battery charging"
				text: qsTrId("pagecontrollableloads_battery_at_grey_x_soc_reserve_for_battery_charging")
						.arg(Theme.color_font_secondary)
						.arg(startingBatterySoc.dataItem.value)
				textFormat: Text.RichText
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/ReservationBasePower"
			}

			ListQuantityField {
				unit: VenusOS.Units_Watt
				//% "At %1% SOC, reserve for battery charging"
				text: qsTrId("pagecontrollableloads_battery_at_x_soc_reserve_for_battery_charging").arg(100)
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/ReservationEndPower"
				//% "Between the SOC set in “Allow additional loads from battery SOC” and 100% SOC, the reserved power is adjusted gradually between these values. This allows battery charging to decrease as the SOC rises, leaving more surplus power available for controlled devices."
				caption: qsTrId("pagecontrollableloads_battery_between_the_soc")
			}
		}
	}
}
