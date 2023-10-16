/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQml
import Victron.VenusOS

BaseDevice {
	id: root

	Component.onCompleted: deviceInstance = Global.mockDataSimulator.deviceCount++
}
