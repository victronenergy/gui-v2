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
			ListSecurityWarningSwitch {
				id: vncOnLan

				//% "Enable Remote Console"
				text: qsTrId("settings_remoteconsole_enable_on_lan")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/System/VncLocal"

				bottomContentChildren: ListLabel {
					allowed: text.length > 0
					topPadding: 0
					bottomPadding: 0
					color: Theme.color_font_secondary
					//% "Security warning: only enable the console when the GX device is connected to a trusted network."
					text: qsTrId("settings_remoteconsole_enable_on_lan_warning")
				}
			}

			ListTextItem {
				//% "Remote Console on VRM - status"
				text: qsTrId("settings_remoteconsole_vrm_status")
				secondaryText: {
					if (vrmPortalMode.value !== VenusOS.Vrm_PortalMode_Full) {
						//% "Turned Off"
						return qsTrId("settings_remoteconsole_vrm_turned_off")
					} else if (remoteSupportIpAndPort.isValid && remoteSupportIpAndPort.value !== 0) {
						return CommonWords.online
					} else {
						return CommonWords.offline
					}
				}

				VeQuickItem {
					id: vrmPortalMode
					uid: Global.systemSettings.serviceUid + "/Settings/Network/VrmPortal"
				}
				VeQuickItem {
					id: remoteSupportIpAndPort
					uid: Global.systemSettings.serviceUid + "/Settings/System/RemoteSupportIpAndPort"
				}
			}
		}
	}
}
