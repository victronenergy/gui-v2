/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("platform")
	readonly property bool isContainer: _isContainer.value === true

	function reboot() {
		_reboot.setValue(true)
	}

	property VeQuickItem _reboot: VeQuickItem {
		 uid: Global.venusPlatform.serviceUid + "/Device/Reboot"
	}

	property VeQuickItem _isContainer: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Device/IsContainer"
	}

	Component.onCompleted: Global.venusPlatform = root
}
