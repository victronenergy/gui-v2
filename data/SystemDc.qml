/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	property real power: _systemPower.value === undefined ? NaN : (_systemPower.value || 0)
	onPowerChanged: Utils.updateMaximumValue("system.dc.power", power)

	property VeQuickItem _systemPower: VeQuickItem { uid: veSystem.childUId("/Dc/System/Power") }
}
