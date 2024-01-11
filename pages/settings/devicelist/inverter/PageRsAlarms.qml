/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	readonly property int numberOfPhases: phases.valid ? phases.value : 1
	property alias rsModel: settingsListView.model

	VeQuickItem {
		id: phases
		uid: root.bindPrefix + "/Ac/NumberOfPhases"
	}

	GradientListView {
		id: settingsListView

		delegate: VeBusAlarm {
			text: modelData.text
			bindPrefix: root.bindPrefix
			numOfPhases: root.numberOfPhases
			alarmSuffix: modelData.alarmSuffix
		}
	}
}
