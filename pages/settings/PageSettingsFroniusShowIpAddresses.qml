/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	IpAddressListView {
		id: settingsListView

		addressesUid: Global.systemSettings.serviceUid + "/Settings/Fronius/KnownIPAddresses"
		header: ListNavigation {
			bottomInset: Theme.geometry_listItem_itemSeparator_height
			bottomPadding: bottomInset + topPadding

			//% "Rescan for IP addresses"
			text: qsTrId("settings_fronius_rescan_for_ip_addresses")
			iconSource: "qrc:/images/icon_refresh_32.svg"
			iconColor: Theme.color_ok
			showAccessLevel: VenusOS.User_AccessType_Installer
			onClicked: {
				settingsListView.clearAddresses()
				scanItem.setValue(1)
			}
		}
	}

	VeQuickItem {
		id: scanItem

		uid: BackendConnection.serviceUidForType("fronius") + "/AutoDetect"
	}
}
