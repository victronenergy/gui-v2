/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string gateway
	property string service: BackendConnection.serviceUidFromName("com.victronenergy.canopenmotordrive.%1".arg(gateway), 0)

	VeQuickItem {
		id: scanItem

		uid: root.service + "/Scan"
	}

	VeQuickItem {
		id: scanProgressItem

		uid: root.service + "/ScanProgress"
	}

	GradientListView {
		model: VisibleItemModel {
			ListButton {
				//% "Scan for motor drives"
				text: qsTrId("page_settings_canopenmotordrive_scan_for_motor_drives")
				secondaryText: scanItem.value ? CommonWords.scanning.arg(Math.round(scanProgressItem.value || 0)) : CommonWords.press_to_scan
				onClicked: scanItem.setValue(!scanItem.value)
				preferredVisible: userHasWriteAccess
			}

			ListText {
				//% "Discovered motor drive IDs"
				text: qsTrId("page_settings_canopenmotordrive_discovered_motor_drive_ids")
				dataItem.uid: root.service + "/DiscoveredNodes"
				dataItem.invalidate: false
			}
		}
	}
}
