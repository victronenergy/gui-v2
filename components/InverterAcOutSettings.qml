/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SettingsColumn {
	id: root

	property string bindPrefix
	readonly property bool isInverterCharger: isInverterChargerItem.value === 1
	readonly property AcPhase acPhase: acPhaseNumber.value === 2 ? inverterData.phase3
			: acPhaseNumber.value === 1 ? inverterData.phase2
			: inverterData.phase1

	width: parent ? parent.width : 0

	VeQuickItem {
		id: isInverterChargerItem
		uid: root.bindPrefix + "/IsInverterCharger"
	}

	AcOutput {
		id: inverterData

		serviceUid: root.bindPrefix
	}

	ListQuantityGroup {
		text: CommonWords.ac_out
		preferredVisible: !root.isInverterCharger
		model: QuantityObjectModel {
			QuantityObject { object: inverterData.phase1; key: "voltage"; unit: VenusOS.Units_Volt_AC }
			QuantityObject { object: inverterData.phase1; key: "current"; unit: VenusOS.Units_Amp }
			QuantityObject { object: inverterData.phase1; key: "power"; unit: VenusOS.Units_Watt }
		}
	}

	ListQuantityGroup {
		//: %1 = phase number (1-3)
		//% "AC Out L%1"
		text: qsTrId("inverter_ac-out_num").arg(acPhaseNumber.isValid ? acPhaseNumber.value + 1 : 1)
		preferredVisible: root.isInverterCharger
		model: QuantityObjectModel {
			QuantityObject { object: root.acPhase; key: "voltage"; unit: VenusOS.Units_Volt_AC }
			QuantityObject { object: root.acPhase; key: "current"; unit: VenusOS.Units_Amp }
			QuantityObject { object: root.acPhase; key: "power"; unit: VenusOS.Units_Watt }
			QuantityObject { object: root.acPhase; key: "frequency"; unit: VenusOS.Units_Hertz }
		}

		VeQuickItem {
			id: acPhaseNumber
			uid: root.bindPrefix + "/Settings/System/AcPhase"
		}
	}
}
