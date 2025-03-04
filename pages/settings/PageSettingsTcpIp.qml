/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string network: "Wired"
	property string tech: "ethernet"
	property alias service: networkServices.service

	VeQuickItem {
		id: setValueItem
		uid: Global.venusPlatform.serviceUid + "/Network/SetValue"
	}

	GradientListView {
		id: settingsListView
		model: networkServices.ready ? connectedModel : disconnectedModel
	}

	VisibleItemModel {
		id: disconnectedModel

		ListText {
			text: CommonWords.state
			secondaryText: networkServices.wifi
					 //% "Connection lost"
					? qsTrId("settings_tcpip_connection_lost")
					 //% "Unplugged"
					: qsTrId("settings_tcpip_connection_unplugged")
		}
	}

	NetworkSettingsPageModel {
		id: connectedModel

		networkServices: networkServices
	}

	NetworkServices {
		id: networkServices

		tech: root.tech
	}
}
