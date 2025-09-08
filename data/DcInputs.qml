/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property real power: model.totalPower
	readonly property real current: model.totalCurrent
	readonly property real maximumPower: _maximumPower.valid ? _maximumPower.value : NaN

	readonly property DcMeterDeviceModel model: DcMeterDeviceModel {
		serviceTypes: ["alternator", "fuelcell", "dcsource", "dcgenset"]
	}

	readonly property VeQuickItem _maximumPower: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Dc/Input/Power/Max"
	}

	Component.onCompleted: Global.dcInputs = root
}
