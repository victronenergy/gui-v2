/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	readonly property int numberOfPhases: phases.valid ? phases.value : 1

	VeQuickItem {
		id: phases
		uid: root.bindPrefix + "/Ac/NumberOfPhases"
	}

	DelegateComponentModel {
		id: validAlarmsModel

		DelegateComponent {
			id: phaseRotationAlarmDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/Alarms/PhaseRotation" }
			preferredVisible: phaseRotationAlarmDC.dataItem.valid
			VeBusAlarm {
				//% "Phase rotation"
				text: qsTrId("rssystemalarms_phase_rotation")
				bindPrefix: root.bindPrefix
				alarmSuffix: "/PhaseRotation"
				errorItem: true
				multiPhase: false
			}
		}

		DelegateComponent {
			id: temperatureAlarmDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/Alarms/HighTemperature" }
			preferredVisible: temperatureAlarmDC.dataItem.valid
			VeBusAlarm {
				text: CommonWords.temperature
				bindPrefix: root.bindPrefix
				numOfPhases: root.numberOfPhases
				alarmSuffix: "/HighTemperature"
				multiPhase: false
			}
		}

		DelegateComponent {
			id: overloadAlarmDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/Alarms/Overload" }
			preferredVisible: overloadAlarmDC.dataItem.valid
			VeBusAlarm {
				//% "Overload"
				text: qsTrId("rssystemalarms_overload")
				bindPrefix: root.bindPrefix
				alarmSuffix: "/Overload"
				multiPhase: false
			}
		}
	}

	DelegateComponentModel {
		id: noAlarmsModel

		DelegateComponent {
			PrimaryListLabel {
				//% "No system alarms"
				text: qsTrId("rs_no_system_alarms")
			}
		}
	}

	GradientListView {
		model: phaseRotationAlarmDC.preferredVisible || temperatureAlarmDC.preferredVisible || overloadAlarmDC.preferredVisible ? validAlarmsModel : noAlarmsModel
	}
}
