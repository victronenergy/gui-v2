/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib

Item {
	id: root

	property real power: _systemPower.value === undefined ? NaN : (_systemPower.value || 0)

	property VeQuickItem _systemPower: VeQuickItem { uid: veSystem.childUId("/Dc/System/Power") }
}
