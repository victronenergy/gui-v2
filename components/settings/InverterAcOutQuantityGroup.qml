/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	property string bindPrefix
	property bool isInverterCharger

	width: parent ? parent.width : 0

	AcOutput {
		id: inverterData

		serviceUid: root.bindPrefix
	}

	ListQuantityGroup {
		text: CommonWords.ac_out
		visible: !root.isInverterCharger
		textModel: [
			{ value: inverterData.phase1.voltage, unit: VenusOS.Units_Volt },
			{ value: inverterData.phase1.current, unit: VenusOS.Units_Amp },
			{ value: inverterData.phase1.power, unit: VenusOS.Units_Watt },
		]
	}

	ListQuantityGroup {
		readonly property AcPhase acPhase: acPhaseNumber.value === 2 ? inverterData.phase3
				: acPhaseNumber.value === 1 ? inverterData.phase2
				: inverterData.phase1

		//: %1 = phase number (1-3)
		//% "AC Out L%1"
		text: qsTrId("inverter_ac-out_num").arg(isNaN(acPhase.value) ? 1 : acPhase.value + 1)
		visible: root.isInverterCharger
		textModel: [
			{ value: acPhase.voltage, unit: VenusOS.Units_Volt },
			{ value: acPhase.current, unit: VenusOS.Units_Amp },
			{ value: acPhase.power, unit: VenusOS.Units_Watt },
			{ value: acPhase.frequency, unit: VenusOS.Units_Hertz },
		]

		VeQuickItem {
			id: acPhaseNumber
			uid: root.bindPrefix + "/Settings/System/AcPhase"
		}
	}
}
