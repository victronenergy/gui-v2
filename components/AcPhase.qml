/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property string serviceUid
	readonly property real frequency: _frequency.value === undefined ? NaN : _frequency.value
	readonly property real current: _current.value === undefined ? NaN : _current.value
	readonly property real voltage: _voltage.value === undefined ? NaN : _voltage.value
	readonly property real power: _power.value === undefined ? NaN : _power.value
	readonly property bool valid: !isNaN(frequency)
								  && !isNaN(current)
								  && !isNaN(voltage)
								  && !isNaN(power)

	property DataPoint _frequency: DataPoint {
		source: serviceUid + "/F"
	}

	property DataPoint _current: DataPoint {
		source: serviceUid + "/I"
	}

	property DataPoint _voltage: DataPoint {
		source: serviceUid + "/V"
	}

	property DataPoint _power: DataPoint {
		source: serviceUid + "/P"
	}
}
