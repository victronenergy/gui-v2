/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	property int inputNumber: model.index + 1
	readonly property int inputType: isNaN(_type.value) ? -1 : _type.value
	readonly property real currentLimit: _currentLimit.value === undefined ? -1 : _currentLimit.value
	readonly property bool currentLimitAdjustable: _currentLimitAdjustable.value === 1

	property DataPoint _type: DataPoint {
		source: "com.victronenergy.settings/Settings/SystemSetup/AcInput" + inputNumber
	}

	readonly property VeQuickItem _currentLimit: VeQuickItem {
		uid: inverter.serviceUid + "/Ac/In/" + inputNumber + "/CurrentLimit"
	}

	readonly property VeQuickItem _currentLimitAdjustable: VeQuickItem {
		uid: inverter.serviceUid + "/Ac/In/" + inputNumber + "/CurrentLimitIsAdjustable"
	}

	function setCurrentLimit(currentLimit) {
		_currentLimit.setValue(currentLimit)
	}
}
