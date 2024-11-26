/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListQuantityGroup {
	id: root

	property string bindPrefix

	//: DC output measurement values
	//% "Output"
	text: qsTrId("dc_output")
	textModel: [
		{ value: dcVoltage.value, unit: VenusOS.Units_Volt_DC },
		{ value: dcCurrent.value, unit: VenusOS.Units_Amp, visible: dcCurrent.isValid },
		{ value: dcPower.value, unit: VenusOS.Units_Watt, visible: dcPower.isValid },
	]

	VeQuickItem {
		id: dcVoltage
		uid: root.bindPrefix + "/Dc/0/Voltage"
	}
	VeQuickItem {
		id: dcCurrent
		uid: root.bindPrefix + "/Dc/0/Current"
	}
	VeQuickItem {
		id: dcPower
		uid: root.bindPrefix + "/Dc/0/Power"
	}
}
