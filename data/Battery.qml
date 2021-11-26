/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib

Item {
	property real stateOfCharge: _batterySoC.value || 0

	property VeQuickItem _batterySoC: VeQuickItem { uid: veSystem.childUId("/Dc/Battery/Soc") }
}
