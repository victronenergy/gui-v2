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
				//% "Limiting the maximum charging power can leave room for lower-priority devices to run at the same time."
				caption: qsTrId("pagecontrollableloads_evcs_limiting_the_maximum")
			}

			ListSwitch {
				preferredVisible: dataItem.valid
				//% "Remember detected EV phases"
				text: qsTrId("pagecontrollableloads_evcs_remember_detected_ev_phases")
				dataItem.uid: root.device ? root.device.serviceUid + "/S2/0/RmSettings/RememberEvPhases" : ""
				//% "Reuses the last detected phase configuration for new charging sessions. Recommended only for a single EV, or when all EVs using this station support the same 1-, 2-, or 3-phase configuration."
				caption: qsTrId("pagecontrollableloads_evcs_reuses_the_last_detected")
			}
		}
	}
}
