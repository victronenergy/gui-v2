/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	title: CommonWords.batteries

	GradientListView {
		model: batteryModel
		delegate: SystemBatteryDelegate {}
	}

	SystemBatteryDeviceModel {
		id: batteryModel
	}
}
