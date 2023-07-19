/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQml
import Victron.VenusOS

QtObject {
	id: root

	property string source
	property var value: Global.mockDataSimulator ? Global.mockDataSimulator.mockDataValues[source] : undefined
	property real min: 0
	property real max: 100
	property bool invalidate: true

	function setValue(v) {
		value = v
	}
}
