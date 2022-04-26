/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property int state

	property QtObject loads: QtObject {
		readonly property real power: ac.consumption.power + dc.power
		onPowerChanged: Utils.updateMaximumValue("system.loads.power", power)
	}

	property QtObject generator: QtObject {
		// TODO add DC generator input data.
		readonly property real power: ac.genset.power
		onPowerChanged: Utils.updateMaximumValue("system.generator.power", power)
	}

	property SystemAc ac: SystemAc {}
	property SystemDc dc: SystemDc {}

	function reset() {
		ac.reset()
		dc.reset()
	}

	Component.onCompleted: Global.system = root
}
