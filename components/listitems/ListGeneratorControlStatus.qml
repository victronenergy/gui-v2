/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListText {
	id: root

	required property string startStopBindPrefix

	//% "Control status"
	text: qsTrId("list_generator_control_status")
	secondaryText: activeCondition.isAutoStarted && generatorState.value === VenusOS.Generators_State_Running
					   ? CommonWords.autostarted_dot_running_by.arg(Global.generators.runningByText(activeCondition.value))
					   : generatorState.valid && activeCondition.valid
						 ? Global.generators.stateAndCondition(generatorState.value, activeCondition.value)
						 : ""

	VeQuickItem {
		id: activeCondition
		readonly property bool isAutoStarted: valid && Global.generators.isAutoStarted(value)
		uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/RunningByConditionCode" : ""
	}

	VeQuickItem {
		id: generatorState
		uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/State" : ""
	}
}

