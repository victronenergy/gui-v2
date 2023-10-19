/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQml
import Victron.VenusOS

BaseDevice {
	id: root

	description: name

	Component.onCompleted: deviceInstance = Global.mockDataSimulator.deviceCount++
}
