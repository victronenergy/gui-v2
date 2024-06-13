/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextItem {
	id: root

	text: CommonWords.error
	secondaryText: {
		switch (dataItem.value) {
		case 0: return CommonWords.formatError(CommonWords.no_error, 0)
		//% "Remote switch control disabled"
		case 1: return CommonWords.formatError(qsTrId("settings_remote_switch_control_disabled"), 1)
		//% "Generator in fault condition"
		case 2: return CommonWords.formatError(qsTrId("settings_generator_in_fault_condition"), 2)
		//% "Generator not detected at AC input"
		case 3: return CommonWords.formatError(qsTrId("settings_generator_not_detected"), 3)
		default: return ""
		}
	}
}
