/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib

Item {
	property real stateOfCharge: _batterySoC.value || 0
	property real timeToGo: _timeToGo.value || 0    // in seconds

	property VeQuickItem _batterySoC: VeQuickItem { uid: veSystem.childUId("/Dc/Battery/Soc") }

	property VeQuickItem _timeToGo: VeQuickItem { uid: veSystem.childUId("/Dc/Battery/TimeToGo") }
}
