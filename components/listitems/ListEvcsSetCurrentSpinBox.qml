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
	from: clickable ? 6 : 0
	to: clickable ? (maxCurrent.valid ? maxCurrent.value : 32) : Global.int32Max
	stepSize: 1

	// When displaying current in a control card, and the control is not clickable,
	// the display should update from the /Current value instead of /SetCurrent.
	// This gives feedback to the user of the present current flowing in the EVCS
	// device. This control is hidden when not manual mode in the EVCS settings page.
	dataItem.uid: clickable ? serviceUid + "/SetCurrent" : serviceUid + "/Current"
	writeAccessLevel: VenusOS.User_AccessType_User
	preferredVisible: dataItem.valid

	VeQuickItem {
		id: maxCurrent
		uid: root.serviceUid + "/MaxCurrent"
	}
}
