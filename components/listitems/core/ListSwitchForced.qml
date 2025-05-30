/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListSwitch {
	id: root

	readonly property bool _forced: dataItem.value === VenusOS.Switch_ForcedOff || dataItem.value === VenusOS.Switch_ForcedOn

	checked: dataItem.value === 1 || dataItem.value === VenusOS.Switch_ForcedOn
	interactive: dataItem.valid && !_forced

	secondaryText: _forced && checked
		  //% "Forced on"
		? qsTrId("settings_dvcc_switch_forced_on")
		: _forced && !checked
			//% "Forced off"
		  ? qsTrId("settings_dvcc_switch_forced_off")
		  : ""
}
