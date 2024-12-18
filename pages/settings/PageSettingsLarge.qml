/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property bool allModificationsDisabled: allModificationsDisabledItem.isValid && allModificationsDisabledItem.value === 1

	VeQuickItem {
		id: allModificationsDisabledItem
		uid: Global.systemSettings.serviceUid + "/Settings/System/SystemIntegrity/AllModificationsDisabled"
	}

	GradientListView {
		model: ObjectModel {
			PrimaryListLabel {
				//% "Note that these features are not officially supported by Victron. Please turn to community.victronenergy.com for questions.\n\nDocumentation at https://ve3.nl/vol"
				text: qsTrId("settings_large_features_not_offically_supported") + (root.allModificationsDisabled ? "\n\nVenus OS Large features are disabled, since \"Disable all modifications\" under \"Settings -> Support & Troubleshoot -> Customization checks\" is enabled." : "")
			}

			ListSwitch {
				id: signalk

				//% "Signal K"
				text: qsTrId("settings_large_signal_k")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
				allowed: dataItem.isValid
				enabled: userHasWriteAccess && !root.allModificationsDisabled
			}

			PrimaryListLabel {
				//% "Access Signal K at http://venus.local:3000 and via VRM."
				text: qsTrId("settings_large_access_signal_k")
				allowed: signalk.checked
			}

			ListNavigation {
				id: nodered

				//% "Node-RED"
				text: qsTrId("settings_large_node_red")
				allowed: nodeRedModeItem.isValid
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsNodeRed.qml", {"title": nodered.text })

				VeQuickItem {
					id: nodeRedModeItem
					uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
				}
			}
		}
	}
}
