/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DcDevice {
	id: input

	readonly property int inputType: Global.dcInputs.inputType(serviceUid, monitorMode)
	readonly property int monitorMode: _monitorMode.valid ? _monitorMode.value : -1

	readonly property VeQuickItem _monitorMode: VeQuickItem {
		uid: input.serviceUid + "/Settings/MonitorMode"
	}
}
