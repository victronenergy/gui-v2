/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("platform")

	function reboot() {
		_reboot.setValue(true)
	}

	property VeQuickItem _reboot: VeQuickItem {
		 uid: Global.venusPlatform.serviceUid + "/Device/Reboot"
	}

	Component.onCompleted: Global.venusPlatform = root
}
