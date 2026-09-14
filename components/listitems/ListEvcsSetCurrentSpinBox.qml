/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListSpinBox {
	id: root

	required property string serviceUid
	required property bool manualMode

	text: CommonWords.charge_current
	suffix: Units.defaultUnitString(VenusOS.Units_Amp)
	from: manualMode ? 6 : 0
	to: manualMode ? maxCurrent.valid ? maxCurrent.value : 32 : Global.int32Max
	stepSize: 1
	dataItem.uid: manualMode ? serviceUid + "/SetCurrent" : serviceUid + "/Current"
	writeAccessLevel: VenusOS.User_AccessType_User
	preferredVisible: dataItem.valid
	interactive: dataItem.valid && manualMode

	VeQuickItem {
		id: maxCurrent
		uid: root.serviceUid + "/MaxCurrent"
	}
}
