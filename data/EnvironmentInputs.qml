/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property FilteredDeviceModel model: FilteredDeviceModel {
		serviceTypes: ["temperature"]
	}
}
