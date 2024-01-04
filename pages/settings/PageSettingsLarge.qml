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
				visible: dataItem.isValid
				writeAccessLevel: VenusOS.User_AccessType_Installer
			}

			ListLabel {
				//% "Access Signal K at http://venus.local:3000 and via VRM"
				text: qsTrId("settings_large_access_signal_k")
				visible: signalk.checked
			}

			ListRadioButtonGroup {
				id: nodered

				//% "Node-RED"
				text: qsTrId("settings_large_node_red")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
				visible: dataItem.isValid
				writeAccessLevel: VenusOS.User_AccessType_Installer
				optionModel: [
					{ display: CommonWords.disabled, value: VenusOS.NodeRed_Mode_Disabled },
					{ display: CommonWords.enabled, value: VenusOS.NodeRed_Mode_Enabled },
					//% "Enabled (safe mode)"
					{ display: qsTrId("settings_large_enabled_safe_mode"), value: VenusOS.NodeRed_Mode_EnabledWithSafeMode },
				]
			}

			ListLabel {
				//% "Access Node-RED at https://venus.local:1881 and via VRM"
				text: qsTrId("settings_large_access_node_red")
				visible: nodered.currentValue > 0
			}
		}
	}
}
