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
				//% "Expected power consumption"
				text: qsTrId("pagecontrollableloads_acload_expected_power_consumption")
				dataItem.uid: root.device ? root.device.serviceUid + "/S2/0/RmSettings/PowerSetting" : ""
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				preferredVisible: dataItem.valid
			}
			ListTimeSelector {
				//% "Minimum run duration when turned on"
				text: qsTrId("pagecontrollableloads_acload_minimum_run_duration")
				showMinuteSecondOnly: true
				dataItem.uid: root.device? root.device.serviceUid + "/S2/0/RmSettings/OffHysteresis" : ""
				preferredVisible: dataItem.valid
			}
			ListTimeSelector {
				//% "Minimum rest duration when turned off"
				text: qsTrId("pagecontrollableloads_acload_minimum_rest_duration")
				showMinuteSecondOnly: true
				dataItem.uid: root.device? root.device.serviceUid + "/S2/0/RmSettings/OnHysteresis" : ""
				preferredVisible: dataItem.valid
			}
		}
	}
}
