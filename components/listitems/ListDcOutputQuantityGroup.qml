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
	model: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject { object: dcVoltage; unit: VenusOS.Units_Volt_DC; defaultValue: "--" }
		QuantityObject { object: dcCurrent; unit: VenusOS.Units_Amp }
		QuantityObject { object: dcPower; unit: VenusOS.Units_Watt }
	}

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
