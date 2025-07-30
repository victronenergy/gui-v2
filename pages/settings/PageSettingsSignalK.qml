/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: VisibleItemModel {
			ListSwitch {
				id: signalk

				//% "Signal K"
				text: qsTrId("settings_large_signal_k")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
			}

			ListLink {
				//% "Access Signal K"
				text: qsTrId("settings_large_access_signal_k")
				url: BackendConnection.signalKUrl
				preferredVisible: signalk.checked
			}
		}
	}
}
