/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: inverterCharger

	readonly property int state: _state.value === undefined ? -1 : _state.value
	readonly property int mode: _mode.value === undefined ? -1 : _mode.value
	readonly property real nominalInverterPower: _nominalInverterPower.value === undefined ? NaN : _nominalInverterPower.value

	readonly property int numberOfAcInputs: _numberOfAcInputs.value === undefined ? NaN : _numberOfAcInputs.value

	readonly property VeQuickItem _state: VeQuickItem {
		uid: inverterCharger.serviceUid + "/State"
	}

	readonly property VeQuickItem _nominalInverterPower: VeQuickItem {
		uid: inverterCharger.serviceUid + "/Ac/Out/NominalInverterPower"
		onValueChanged: if (!!Global.inverterChargers) Global.inverterChargers.refreshNominalInverterPower()
	}

	readonly property VeQuickItem _mode: VeQuickItem {
		uid: inverterCharger.serviceUid + "/Mode"
	}

	readonly property VeQuickItem _numberOfAcInputs: VeQuickItem {
		uid: inverterCharger.serviceUid + "/Ac/NumberOfAcInputs"
	}
}
