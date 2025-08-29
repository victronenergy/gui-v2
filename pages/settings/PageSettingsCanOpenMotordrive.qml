/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string service: BackendConnection.serviceUidFromName("com.victronenergy.canopenmotordrive", 0)

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
				//% "Scan for nodes"
				text: qsTrId("page_settings_canopenmotordrive_scan_for_nodes")
				secondaryText: scanItem.value ? CommonWords.scanning.arg(Math.round(scanProgressItem.value || 0)) : CommonWords.press_to_scan
				onClicked: scanItem.setValue(!scanItem.value)
				preferredVisible: userHasWriteAccess
			}

			ListText {
				//% "Discovered nodes"
				text: qsTrId("page_settings_canopenmotordrive_discovered_nodes")
				dataItem.uid: root.service + "/DiscoveredNodes"
				dataItem.invalidate: false
			}
		}
	}
}
