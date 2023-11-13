/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		header: ListLabel {
			//% "No alarms"
			text: qsTrId("dcmeter_alarms_no_alarms")
			visible: !lowVoltage.visible
					 && !highVoltage.visible
					 && !lowAuxVoltage.visible
					 && !highAuxVoltage.visible
					 && !lowTemp.visible
					 && !highTemp.visible
		}

		model: ObjectModel {
			ListAlarm {
				id: lowVoltage

				//% "Low voltage"
				text: qsTrId("dcmeter_alarms_low_voltage")
				dataSource: root.bindPrefix + "/Alarms/LowVoltage"
				visible: defaultVisible && dataValid
			}

			ListAlarm {
				id: highVoltage

				//% "High voltage"
				text: qsTrId("dcmeter_alarms_high_voltage")
				dataSource: root.bindPrefix + "/Alarms/HighVoltage"
				visible: defaultVisible && dataValid
			}

			ListAlarm {
				id: lowAuxVoltage

				//% "Low aux voltage"
				text: qsTrId("dcmeter_alarms_low_aux_voltage")
				dataSource: root.bindPrefix + "/Alarms/LowStarterVoltage"
				visible: defaultVisible && dataValid
			}

			ListAlarm {
				id: highAuxVoltage

				//% "High aux voltage"
				text: qsTrId("dcmeter_alarms_high_aux_voltage")
				dataSource: root.bindPrefix + "/Alarms/HighStarterVoltage"
				visible: defaultVisible && dataValid
			}

			ListAlarm {
				id: lowTemp

				text: CommonWords.low_temperature
				dataSource: root.bindPrefix + "/Alarms/LowTemperature"
				visible: defaultVisible && dataValid
			}

			ListAlarm {
				id: highTemp

				text: CommonWords.high_temperature
				dataSource: root.bindPrefix + "/Alarms/HighTemperature"
				visible: defaultVisible && dataValid
			}
		}
	}
}
