/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SettingsColumn {
	id: root

	required property string bindPrefix

	preferredVisible: consumptionLimitSwitch.preferredVisible || consumptionPowerLimitSpinBox.preferredVisible
			|| consumptionCurrentLimitSpinBox.preferredVisible
	width: parent ? parent.width : 0

	ListSwitch {
		id: consumptionLimitSwitch

		//% "Consumption limit"
		text: qsTrId("ac-limits-consumptionsettings_consumption_limit")
		dataItem.uid: root.bindPrefix + "/Ac/Limits/Consumption/Active"
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		id: consumptionPowerLimitSpinBox

		//% "Consumption power limit"
		text: qsTrId("ac-limits-consumptionsettings_consumption_power_limit")
		dataItem.uid: root.bindPrefix + "/Ac/Limits/Consumption/Power"
		suffix: Units.defaultUnitString(VenusOS.Units_Watt)
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		id: consumptionCurrentLimitSpinBox

		//% "Consumption current limit"
		text: qsTrId("ac-limits-consumptionsettings_consumption_current_limit")
		dataItem.uid: root.bindPrefix + "/Ac/Limits/Consumption/Current"
		suffix: Units.defaultUnitString(VenusOS.Units_Amp)
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}
}
