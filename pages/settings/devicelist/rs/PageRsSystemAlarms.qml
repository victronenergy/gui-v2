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

	// A VeBusAlarm displays whichever of /Alarms<suffix>, /Alarms/L1<suffix>, /Alarms/L2<suffix>
	// and /Alarms/L3<suffix> are valid; multis connected to the CAN-bus publish only the per phase
	// paths. The row guards below must therefore cover all four paths, otherwise the rows would be
	// filtered out and this page would claim "No system alarms" while alarms are being published.
	VeQuickItem { id: phaseRotationAlarmL1; uid: root.bindPrefix + "/Alarms/L1/PhaseRotation" }
	VeQuickItem { id: phaseRotationAlarmL2; uid: root.bindPrefix + "/Alarms/L2/PhaseRotation" }
	VeQuickItem { id: phaseRotationAlarmL3; uid: root.bindPrefix + "/Alarms/L3/PhaseRotation" }

	VeQuickItem { id: temperatureAlarmL1; uid: root.bindPrefix + "/Alarms/L1/HighTemperature" }
	VeQuickItem { id: temperatureAlarmL2; uid: root.bindPrefix + "/Alarms/L2/HighTemperature" }
	VeQuickItem { id: temperatureAlarmL3; uid: root.bindPrefix + "/Alarms/L3/HighTemperature" }

	VeQuickItem { id: overloadAlarmL1; uid: root.bindPrefix + "/Alarms/L1/Overload" }
	VeQuickItem { id: overloadAlarmL2; uid: root.bindPrefix + "/Alarms/L2/Overload" }
	VeQuickItem { id: overloadAlarmL3; uid: root.bindPrefix + "/Alarms/L3/Overload" }

	DelegateComponentModel {
		id: validAlarmsModel

		DelegateComponent {
			id: phaseRotationAlarmDC
			dataItem: VeQuickItem { uid: root.bindPrefix + "/Alarms/PhaseRotation" }
			preferredVisible: phaseRotationAlarmDC.dataItem.valid || phaseRotationAlarmL1.valid
					|| phaseRotationAlarmL2.valid || phaseRotationAlarmL3.valid
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
			preferredVisible: temperatureAlarmDC.dataItem.valid || temperatureAlarmL1.valid
					|| temperatureAlarmL2.valid || temperatureAlarmL3.valid
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
			preferredVisible: overloadAlarmDC.dataItem.valid || overloadAlarmL1.valid
					|| overloadAlarmL2.valid || overloadAlarmL3.valid
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
