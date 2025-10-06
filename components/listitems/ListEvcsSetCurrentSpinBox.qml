/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListSpinBox {
	id: root

	required property string serviceUid

	text: CommonWords.charge_current
	suffix: Units.defaultUnitString(VenusOS.Units_Amp)
	from: 6
	to: maxCurrent.valid ? maxCurrent.value : 32
	stepSize: 1
	dataItem.uid: serviceUid + "/SetCurrent"
	writeAccessLevel: VenusOS.User_AccessType_User
	preferredVisible: dataItem.valid

	VeQuickItem {
		id: maxCurrent
		uid: root.serviceUid + "/MaxCurrent"
	}
}
