/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
				dataItem.uid: root.bindPrefix + "/Alarms/LowVoltage"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				id: highVoltage

				//% "High voltage"
				text: qsTrId("dcmeter_alarms_high_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/HighVoltage"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				id: lowAuxVoltage

				//% "Low aux voltage"
				text: qsTrId("dcmeter_alarms_low_aux_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/LowStarterVoltage"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				id: highAuxVoltage

				//% "High aux voltage"
				text: qsTrId("dcmeter_alarms_high_aux_voltage")
				dataItem.uid: root.bindPrefix + "/Alarms/HighStarterVoltage"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				id: lowTemp

				text: CommonWords.low_temperature
				dataItem.uid: root.bindPrefix + "/Alarms/LowTemperature"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				id: highTemp

				text: CommonWords.high_temperature
				dataItem.uid: root.bindPrefix + "/Alarms/HighTemperature"
				visible: defaultVisible && dataItem.isValid
			}
		}
	}
}
