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
				unit: VenusOS.Units_Watt
				//% "Reserved power for battery charging at 0% SOC"
				text: qsTrId("pagecontrollableloads_battery_reserved_power_0")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/ReservationBasePower"
			}

			ListQuantityField {
				unit: VenusOS.Units_Watt
				//% "Reduce power per percentage point of SOC by"
				text: qsTrId("pagecontrollableloads_battery_reduce_power")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/ReservationDecrement"
			}

			SettingsListHeader {
				//% "BatteryLife compatibility"
				text: qsTrId("pagecontrollableloads_battery_batterylife_compatibility")
			}

			ListSwitch {
				//% "Pause Opportunity Loads when Active SOC limit exceeds 85%"
				text: qsTrId("page_controllableloads_battery_pause_opportunity_loads")
				dataItem.uid: BackendConnection.serviceUidForType("opportunityloads") + "/BatteryLifeSupport"
				//% "This helps the BatteryLife algorithm recharge the battery to 100%."
				caption: qsTrId("pagecontrollableloads_battery_this_supports_the_batterylife_algorithm")
				captionLabel.font.pixelSize: Theme.font_size_caption
			}
		}
	}
}
