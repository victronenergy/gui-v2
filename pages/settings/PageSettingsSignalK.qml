/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				id: signalkDC
				dataItem: VeQuickItem { uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled" }
				property bool checked: dataItem.value === 1
				ListSwitch {
					id: signalk

					//% "Signal K"
					text: qsTrId("settings_large_signal_k")
					dataItem.uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
				}
			}

			DelegateComponent {
				preferredVisible: signalkDC.checked
				ListLink {
					//% "Access Signal K"
					text: qsTrId("settings_large_access_signal_k")
					url: BackendConnection.signalKUrl
				}
			}
		}
	}
}
