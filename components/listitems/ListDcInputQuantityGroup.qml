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
	preferredVisible: inVoltage.valid || inPower.valid
	model: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject { object: inVoltage; unit: VenusOS.Units_Volt_DC }
		QuantityObject { object: inCurrent; unit: VenusOS.Units_Amp }
		QuantityObject { object: inPower; unit: VenusOS.Units_Watt }
	}

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
