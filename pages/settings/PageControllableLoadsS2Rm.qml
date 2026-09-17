/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property Device device

	VeQuickItem {
		id: veQuickItem
		uid: root.device? root.device.serviceUid + "/S2/0/RmSettings/OnHysteresis" : ""
	}
	VeQuickItem {
		id: veQuickItem2
		uid: root.device? root.device.serviceUid + "/S2/0/RmSettings/OffHysteresis" : ""
	}
	VeQuickItem {
		id: veQuickItem3
		uid: root.device ? root.device.serviceUid + "/S2/0/RmSettings/PowerSetting" : ""
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				preferredVisible: veQuickItem3.valid
				ListQuantityField {
					unit: VenusOS.Units_Watt
					//% "Expected power consumption"
					text: qsTrId("pagecontrollableloads_acload_expected_power_consumption")
					dataItem.uid: root.device ? root.device.serviceUid + "/S2/0/RmSettings/PowerSetting" : ""
				}
			}
			DelegateComponent {
				preferredVisible: veQuickItem2.valid
				ListQuantityField {
					unit: VenusOS.Units_Time_Second
					//% "Minimum run duration when turned on"
					text: qsTrId("pagecontrollableloads_acload_minimum_run_duration")
					dataItem.uid: root.device? root.device.serviceUid + "/S2/0/RmSettings/OffHysteresis" : ""
				}
			}
			DelegateComponent {
				preferredVisible: veQuickItem.valid
				ListQuantityField {
					unit: VenusOS.Units_Time_Second
					//% "Minimum rest duration when turned off"
					text: qsTrId("pagecontrollableloads_acload_minimum_rest_duration")
					dataItem.uid: root.device? root.device.serviceUid + "/S2/0/RmSettings/OnHysteresis" : ""
				}
			}
		}
	}
}
