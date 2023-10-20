/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "motorDrives"
	}

	Component.onCompleted: Global.motorDrives = root
}
