/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListQuantityGroup {
	id: root

	property string bindPrefix

	//: DC input measurement values
	//% "Input"
	text: qsTrId("dc_input")
	visible: defaultVisible && (inVoltage.isValid || inPower.isValid)
	textModel: [
		{ value: inVoltage.value, unit: VenusOS.Units_Volt, visible: inVoltage.isValid },
		{ value: inCurrent.value, unit: VenusOS.Units_Amp, visible: inCurrent.isValid },
		{ value: inPower.value, unit: VenusOS.Units_Watt, visible: inPower.isValid },
	]

	VeQuickItem {
		id: inVoltage
		uid: root.bindPrefix + "/Dc/In/V"
	}
	VeQuickItem {
		id: inCurrent
		uid: root.bindPrefix + "/Dc/In/I"
	}
	VeQuickItem {
		id: inPower
		uid: root.bindPrefix + "/Dc/In/P"
	}
}
