/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SettingsColumn {
	id: root

	required property string bindPrefix

	preferredVisible: consumptionLimitSwitch.preferredVisible ||
		consumptionPowerLimitSpinBox.preferredVisible ||
		consumptionL1CurrentLimitSpinBox.preferredVisible ||
		consumptionL2CurrentLimitSpinBox.preferredVisible ||
		consumptionL3CurrentLimitSpinBox.preferredVisible
	width: parent ? parent.width : 0

	ListSwitch {
		id: consumptionLimitSwitch

		//% "Consumption limit"
		text: qsTrId("powerguard_consumption_active")
		dataItem.uid: root.bindPrefix + "/PowerGuard/Consumption/Active"
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		id: consumptionPowerLimitSpinBox

		//% "Consumption power limit"
		text: qsTrId("powerguard_consumption_power_limit")
		dataItem.uid: root.bindPrefix + "/PowerGuard/Consumption/Ac/Power"
		suffix: Units.defaultUnitString(VenusOS.Units_Watt)
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		id: consumptionL1CurrentLimitSpinBox

		//% "Consumption L1 current limit"
		text: qsTrId("powerguard_consumption_l1_current_limit")
		dataItem.uid: root.bindPrefix + "/PowerGuard/Consumption/Ac/L1/Current"
		suffix: Units.defaultUnitString(VenusOS.Units_Amp)
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		id: consumptionL2CurrentLimitSpinBox

		//% "Consumption L2 current limit"
		text: qsTrId("powerguard_consumption_l2_current_limit")
		dataItem.uid: root.bindPrefix + "/PowerGuard/Consumption/Ac/L2/Current"
		suffix: Units.defaultUnitString(VenusOS.Units_Amp)
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		id: consumptionL3CurrentLimitSpinBox

		//% "Consumption L3 current limit"
		text: qsTrId("powerguard_consumption_l3_current_limit")
		dataItem.uid: root.bindPrefix + "/PowerGuard/Consumption/Ac/L3/Current"
		suffix: Units.defaultUnitString(VenusOS.Units_Amp)
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}
}
