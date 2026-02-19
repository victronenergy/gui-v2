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
				//% "Expected power consumption"
				text: qsTrId("pagecontrollableloads_expected_power_consumption")
				dataItem.uid: device?.serviceUid + "/S2/0/RmSettings/PowerSetting"
			}
			ListQuantityField {
				unit: VenusOS.Units_Time_Second
				//% "Minimum run duration when turned on"
				text: qsTrId("pagecontrollableloads_minimum_run_duration")
				dataItem.uid: device?.serviceUid + "/S2/0/RmSettings/OffHysteresis"
			}
			ListQuantityField {
				unit: VenusOS.Units_Time_Second
				//% "Minimum rest duration when turned off"
				text: qsTrId("pagecontrollableloads_minimum_rest_duration")
				dataItem.uid: device?.serviceUid + "/S2/0/RmSettings/OnHysteresis"
			}
		}
	}
}
