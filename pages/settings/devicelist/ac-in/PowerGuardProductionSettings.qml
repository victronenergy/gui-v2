/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SettingsColumn {
	id: root

	required property string bindPrefix

	preferredVisible: productionLimitSwitch.preferredVisible ||
		productionPowerLimitSpinBox.preferredVisible ||
		productionL1CurrentLimitSpinBox.preferredVisible ||
		productionL2CurrentLimitSpinBox.preferredVisible ||
		productionL3CurrentLimitSpinBox.preferredVisible
	width: parent ? parent.width : 0

	ListSwitch {
		id: productionLimitSwitch

		//% "Production limit"
		text: qsTrId("powerguard_production_active")
		dataItem.uid: root.bindPrefix + "/PowerGuard/Production/Active"
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		id: productionPowerLimitSpinBox

		//% "Production power limit"
		text: qsTrId("powerguard_production_power_limit")
		dataItem.uid: root.bindPrefix + "/PowerGuard/Production/Ac/Power"
		suffix: Units.defaultUnitString(VenusOS.Units_Watt)
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		id: productionL1CurrentLimitSpinBox

		//% "Production L1 current limit"
		text: qsTrId("powerguard_production_l1_current_limit")
		dataItem.uid: root.bindPrefix + "/PowerGuard/Production/Ac/L1/Current"
		suffix: Units.defaultUnitString(VenusOS.Units_Amp)
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		id: productionL2CurrentLimitSpinBox

		//% "Production L2 current limit"
		text: qsTrId("powerguard_production_l2_current_limit")
		dataItem.uid: root.bindPrefix + "/PowerGuard/Production/Ac/L2/Current"
		suffix: Units.defaultUnitString(VenusOS.Units_Amp)
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		id: productionL3CurrentLimitSpinBox

		//% "Production L3 current limit"
		text: qsTrId("powerguard_production_l3_current_limit")
		dataItem.uid: root.bindPrefix + "/PowerGuard/Production/Ac/L3/Current"
		suffix: Units.defaultUnitString(VenusOS.Units_Amp)
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}
}
