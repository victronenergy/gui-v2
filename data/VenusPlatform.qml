/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("platform")

	function reboot() {
		_reboot.setValue(true)
	}

	property DataPoint _reboot: DataPoint {
		 source: Global.venusPlatform.serviceUid + "/Device/Reboot"
	}

	Component.onCompleted: Global.venusPlatform = root
}
