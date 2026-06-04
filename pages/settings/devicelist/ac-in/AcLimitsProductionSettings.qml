/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SettingsColumn {
	id: root

	required property string bindPrefix

	preferredVisible: productionLimitSwitch.preferredVisible || productionPowerLimitSpinBox.preferredVisible
			|| productionCurrentLimitSpinBox.preferredVisible
	width: parent ? parent.width : 0

	ListSwitch {
		id: productionLimitSwitch

		//% "Production limit"
		text: qsTrId("ac-limits-productionsettings_production_limit")
		dataItem.uid: root.bindPrefix + "/Ac/Limits/Production/Active"
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		id: productionPowerLimitSpinBox

		//% "Production power limit"
		text: qsTrId("ac-limits-productionsettings_production_power_limit")
		dataItem.uid: root.bindPrefix + "/Ac/Limits/Production/Power"
		suffix: Units.defaultUnitString(VenusOS.Units_Watt)
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		id: productionCurrentLimitSpinBox

		//% "Production current limit"
		text: qsTrId("ac-limits-productionsettings_production_current_limit")
		dataItem.uid: root.bindPrefix + "/Ac/Limits/Production/Current"
		suffix: Units.defaultUnitString(VenusOS.Units_Amp)
		writeAccessLevel: VenusOS.User_AccessType_SuperUser
		preferredVisible: dataItem.valid
	}
}
