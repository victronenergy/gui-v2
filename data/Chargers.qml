/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "chargers"
	}

	Component.onCompleted: Global.chargers = root
}
