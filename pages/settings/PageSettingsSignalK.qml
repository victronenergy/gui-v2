/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property bool allModificationsEnabled: allModificationsEnabledItem.valid && allModificationsEnabledItem.value === 1

	VeQuickItem {
		id: allModificationsEnabledItem
		uid: Global.systemSettings.serviceUid + "/Settings/System/ModificationChecks/AllModificationsEnabled"
	}

	GradientListView {
		model: VisibleItemModel {
			PrimaryListLabel {
				text: CommonWords.all_modifications_disabled
				preferredVisible: !root.allModificationsEnabled
			}

			ListSwitch {
				id: signalk

				//% "Signal K"
				text: qsTrId("settings_large_signal_k")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
				interactive: userHasWriteAccess && root.allModificationsEnabled
			}

			ListLink {
				//% "Access Signal K (local network)"
				text: qsTrId("settings_large_access_signal_k")
				url: "http://venus.local:3000"
				preferredVisible: signalk.checked
			}

			PrimaryListLabel {
				//% "Signal K can also be accessed remotely via VRM."
				text: qsTrId("settings_large_signal_k_vrm_access")
				color: Theme.color_font_secondary
				preferredVisible: signalk.checked
			}
		}
	}
}
