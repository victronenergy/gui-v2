/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string tech: "ethernet" // or "wifi"
	property alias service: networkServices.service
	property NetworkServices ethernetNetworkServices: networkServices

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

		// if tech == "ethernet" these will be the same, otherwise different.
		networkServices: networkServices
		ethernetNetworkServices: root.ethernetNetworkServices
	}

	NetworkServices {
		id: networkServices
		tech: root.tech
	}
}
