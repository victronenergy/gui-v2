/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Page {
	id: root

	property var _addDialog

	function _addOrUpdateAddress(ipAddress, index = -1) {
		let addresses = settingsListView.ipAddresses.value ? settingsListView.ipAddresses.value.split(',') : []
		if (index >= addresses.length) {
			console.warn("invalid index", index, "/IPAddresses length is:", addresses.length)
			return
		}
		if (index < 0) {
			addresses.push(ipAddress)
		} else {
			addresses[index] = ipAddress
		}
		settingsListView.ipAddresses.setValue(addresses.join(','))
	}

	topRightButton: VenusOS.StatusBar_RightButton_Add

	IpAddressListView {
		id: settingsListView

		ipAddresses.uid: Global.systemSettings.serviceUid + "/Settings/Fronius/IPAddresses"
		onIpAddressUpdated: (index, ipAddress) => { root._addOrUpdateAddress(ipAddress, index) }
	}

	Connections {
		target: !!Global.pageManager ? Global.pageManager.statusBar : null
		enabled: root.isCurrentPage

		function onRightButtonClicked() {
			root._addOrUpdateAddress("192.168.1.1", -1)
		}
	}
}


