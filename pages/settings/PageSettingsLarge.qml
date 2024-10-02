/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: ObjectModel {
			ListLabel {
				//% "Note that these features are not officially supported by Victron. Please turn to community.victronenergy.com for questions.\n\nDocumentation at https://ve3.nl/vol"
				text: qsTrId("settings_large_features_not_offically_supported")
			}

			ListSwitch {
				id: signalk

				//% "Signal K"
				text: qsTrId("settings_large_signal_k")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
				allowed: dataItem.isValid
			}

			ListLabel {
				//% "Access Signal K at http://venus.local:3000 and via VRM."
				text: qsTrId("settings_large_access_signal_k")
				allowed: signalk.checked
			}

			ListNavigationItem {
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
