/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("platform")
	readonly property bool isContainer: _isContainer.value === 1

	function reboot() {
		_reboot.setValue(true)
	}

	property VeQuickItem _reboot: VeQuickItem {
		 uid: root.serviceUid + "/Device/Reboot"
	}

	property VeQuickItem _isContainer: VeQuickItem {
		uid: root.serviceUid + "/Device/IsContainer"
	}
}
