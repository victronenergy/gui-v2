/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	property string serviceUid
	property int inputNumber: model.index + 1
	readonly property int inputType: isNaN(_type.value) ? -1 : _type.value
	readonly property real currentLimit: _currentLimit.value === undefined ? -1 : _currentLimit.value
	readonly property bool currentLimitAdjustable: _currentLimitAdjustable.value === 1

	property VeQuickItem _type: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/AcInput" + inputNumber
	}

	readonly property VeQuickItem _currentLimit: VeQuickItem {
		uid: root.serviceUid + "/Ac/In/" + inputNumber + "/CurrentLimit"
	}

	readonly property VeQuickItem _currentLimitAdjustable: VeQuickItem {
		uid: root.serviceUid + "/Ac/In/" + inputNumber + "/CurrentLimitIsAdjustable"
	}

	function setCurrentLimit(currentLimit) {
		_currentLimit.setValue(currentLimit)
	}
}
