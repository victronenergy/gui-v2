/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property int fuseNumber
	property string bindPrefix

	readonly property string fuseName: _nameDataPoint.value || ""
	readonly property int fuseStatus: _statusDataPoint.value === undefined ? -1 : _statusDataPoint.value
	readonly property bool blown: _statusDataPoint.value === 3

	property DataPoint _nameDataPoint: DataPoint {
		source: root.bindPrefix+ "/Fuse/" + root.fuseNumber + "/Name"
	}

	property DataPoint _statusDataPoint: DataPoint {
		source: root.bindPrefix+ "/Fuse/" + root.fuseNumber + "/Status"
	}
}
