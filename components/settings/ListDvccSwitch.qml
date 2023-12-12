/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListSwitch {
	id: root

	readonly property bool _forced: dataValue === Enums.DVCC_ForcedOff || dataValue === Enums.DVCC_ForcedOn

	checked: dataValue === 1 || dataValue === Enums.DVCC_ForcedOn
	enabled: dataValid && userHasWriteAccess && !_forced

	secondaryText: _forced && checked
		  //% "Forced on"
		? qsTrId("settings_dvcc_switch_forced_on")
		: _forced && !checked
			//% "Forced off"
		  ? qsTrId("settings_dvcc_switch_forced_off")
		  : ""
}
