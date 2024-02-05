/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: inverter

	readonly property int state: _state.value === undefined ? -1 : _state.value

	readonly property VeQuickItem _state: VeQuickItem {
		uid: inverter.serviceUid + "/State"
	}

	readonly property var currentPhase: acOutL3.bindPrefix !== "" ? acOutL3
			: acOutL2.bindPrefix !== "" ? acOutL2
			: acOutL1

	readonly property AcData acOutL1: AcData {
		bindPrefix: _phase.value === 0 || _phase.value === undefined ? inverter.serviceUid + "/Ac/Out/L1" : ""
	}
	readonly property AcData acOutL2: AcData {
		bindPrefix:  _phase.value === 1 ? inverter.serviceUid + "/Ac/Out/L2" : ""
	}
	readonly property AcData acOutL3: AcData {
		bindPrefix:  _phase.value === 2 ? inverter.serviceUid + "/Ac/Out/L3" : ""
	}

	readonly property VeQuickItem _phase: VeQuickItem {
		uid: inverter.serviceUid + "/Settings/System/AcPhase"
	}
}
