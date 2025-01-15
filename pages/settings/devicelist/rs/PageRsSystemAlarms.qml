/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	readonly property int numberOfPhases: phases.isValid ? phases.value : 1

	VeQuickItem {
		id: phases
		uid: root.bindPrefix + "/Ac/NumberOfPhases"
	}

	AllowedItemModel {
		id: validAlarmsModel

		VeBusAlarm {
			id: phaseRotationAlarm

			//% "Phase rotation"
			text: qsTrId("rssystemalarms_phase_rotation")
			bindPrefix: root.bindPrefix
			alarmSuffix: "/PhaseRotation"
			errorItem: true
			multiPhase: false
		}

		VeBusAlarm {
			id: temperatureAlarm

			text: CommonWords.temperature
			bindPrefix: root.bindPrefix
			numOfPhases: root.numberOfPhases
			alarmSuffix: "/HighTemperature"
			multiPhase: false
		}

		VeBusAlarm {
			id: overloadAlarm

			//% "Overload"
			text: qsTrId("rssystemalarms_overload")
			bindPrefix: root.bindPrefix
			alarmSuffix: "/Overload"
			multiPhase: false
		}
	}

	AllowedItemModel {
		id: noAlarmsModel

		PrimaryListLabel {
			//% "No system alarms"
			text: qsTrId("rs_no_system_alarms")
		}
	}

	GradientListView {
		model: phaseRotationAlarm.allowed || temperatureAlarm.allowed || overloadAlarm.allowed ? validAlarmsModel : noAlarmsModel
	}
}
