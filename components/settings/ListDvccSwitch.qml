/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListSwitch {
	id: root

	readonly property bool _forced: dataValue === VenusOS.DVCC_ForcedOff || dataValue === VenusOS.DVCC_ForcedOn

	checked: dataValue === 1 || dataValue === VenusOS.DVCC_ForcedOn
	enabled: dataValid && userHasWriteAccess && !_forced

	secondaryText: _forced && checked
		  //% "Forced on"
		? qsTrId("settings_dvcc_switch_forced_on")
		: _forced && !checked
			//% "Forced off"
		  ? qsTrId("settings_dvcc_switch_forced_off")
		  : ""
}
