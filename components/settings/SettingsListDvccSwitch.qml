/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

SettingsListSwitch {
	id: root

	readonly property bool _forced: dataPoint.value === VenusOS.DVCC_ForcedOff || dataPoint.value === VenusOS.DVCC_ForcedOn

	checked: dataPoint.value === 1 || dataPoint.value === VenusOS.DVCC_ForcedOn
	enabled: dataPoint.value !== undefined && userHasWriteAccess && !_forced

	secondaryText: _forced && checked
		  //% "Forced on"
		? qsTrId("settings_dvcc_switch_forced_on")
		: _forced && !checked
			//% "Forced off"
		  ? qsTrId("settings_dvcc_switch_forced_off")
		  : ""
}
