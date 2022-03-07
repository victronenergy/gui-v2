/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	enum State {
		Off = 0,
		LowPower = 1,
		FaultCondition = 2,
		BulkCharging = 3,
		AbsorptionCharging = 4,
		FloatCharging = 5,
		StorageMode = 6,
		EqualisationCharging = 7,
		PassThrough = 8,
		Inverting = 9,
		Assisting = 10,
		Discharging = 256,
		Sustain = 257
	}

	property int state: veSystemState.value || System.State.Off

	property QtObject loads: QtObject {
		readonly property real power: ac.consumption.power + dc.power
		onPowerChanged: Utils.updateMaximumValue("system.loads.power", power)
	}

	property QtObject generator: QtObject {
		// TODO add DC generator input data.
		readonly property real power: ac.genset.power
		onPowerChanged: Utils.updateMaximumValue("system ? system.generator.power : 0", power)
	}

	property SystemAc ac: SystemAc {}
	property SystemDc dc: SystemDc {}

	VeQuickItem {
		id: veSystemState
		uid: veSystem.childUId("SystemState/State")
	}
}
