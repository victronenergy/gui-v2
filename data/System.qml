/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property int state

	// Provides convenience properties for total AC/DC loads.
	property QtObject loads: QtObject {
		readonly property real power: Utils.sumRealNumbers(acPower, dcPower)
		readonly property real acPower: ac.consumption.power
		readonly property real dcPower: dc.power

		// Unlike for power, the AC and DC currents cannot be combined because amps for AC and DC
		// sources are on different scales. So if they are both present, the total is NaN.
		readonly property real current: (acCurrent || 0) !== 0 && (dcCurrent || 0) !== 0
				? NaN
				: (acCurrent || 0) === 0 ? dcCurrent : acCurrent
		readonly property real acCurrent: ac.consumption.current
		readonly property real dcCurrent: dc.current
	}

	property SystemAc ac: SystemAc {}
	property SystemDc dc: SystemDc {}

	property QtObject veBus: QtObject {
		property string serviceUid
		property real power
	}

	function reset() {
		ac.reset()
		dc.reset()
	}

	Component.onCompleted: Global.system = root
}
