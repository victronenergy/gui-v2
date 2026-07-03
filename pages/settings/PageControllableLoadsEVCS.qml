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
				preferredVisible: dataItem.valid
				unit: VenusOS.Units_Watt
				//% "Maximum charging power"
				text: qsTrId("pagecontrollableloads_evcs_maximum_charging_power")
				dataItem.uid: root.device ? root.device.serviceUid + "/S2/0/RmSettings/MaxChargePower" : ""
			}

			ListSwitch {
				preferredVisible: dataItem.valid
				//% "Remember detected EV phases"
				text: qsTrId("pagecontrollableloads_evcs_remember_detected_ev_phases")
				dataItem.uid: root.device ? root.device.serviceUid + "/S2/0/RmSettings/RememberEvPhases" : ""
			}
		}
	}
}
