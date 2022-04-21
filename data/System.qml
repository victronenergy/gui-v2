/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root


	property int state: veSystemState.value || VenusOS.System_State_Off

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

	VeQuickItem {
		id: veSystemState
		uid: veSystem.childUId("SystemState/State")
	}
}
