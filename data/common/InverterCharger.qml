/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: inverterCharger

	readonly property int state: _state.isValid ? _state.value : -1
	readonly property int mode: _mode.isValid ? _mode.value : -1
	readonly property real nominalInverterPower: _nominalInverterPower.isValid ? _nominalInverterPower.value : NaN

	readonly property int numberOfAcInputs: _numberOfAcInputs.isValid ? _numberOfAcInputs.value : NaN

	readonly property VeQuickItem _state: VeQuickItem {
		uid: inverterCharger.serviceUid + "/State"
	}

	readonly property VeQuickItem _nominalInverterPower: VeQuickItem {
		uid: inverterCharger.serviceUid + "/Ac/Out/NominalInverterPower"
		onValueChanged: if (!!Global.inverterChargers)
			Global.inverterChargers.refreshNominalInverterPower()
	}

	readonly property VeQuickItem _mode: VeQuickItem {
		uid: inverterCharger.serviceUid + "/Mode"
	}

	readonly property VeQuickItem _numberOfAcInputs: VeQuickItem {
		uid: inverterCharger.serviceUid + "/Ac/NumberOfAcInputs"
	}
}
