/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	// vebus devices may also show up as AC inputs or batteries, so ensure they do not
	// appear multiple times in the list.
	allowed: sourceModel === Global.inverterChargers.veBusDevices
	secondaryText: Global.system.systemStateToText(state.value)

	onClicked: {
		Global.pageManager.pushPage("/pages/vebusdevice/PageVeBus.qml", { bindPrefix: root.device.serviceUid })
	}

	VeQuickItem {
		id: state
		uid: root.device.serviceUid + "/State"
	}
}
