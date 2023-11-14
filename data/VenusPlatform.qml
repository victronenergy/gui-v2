/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function reboot() {
		_reboot.setValue(true)
	}

	property DataPoint _reboot: DataPoint {
		 source: "com.victronenergy.platform/Device/Reboot"
	}

	Component.onCompleted: Global.venusPlatform = root
}
