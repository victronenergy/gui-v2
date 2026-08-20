/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: highTemperatureItem
		uid: root.bindPrefix + "/Alarms/HighTemperature"
	}
	VeQuickItem {
		id: lowTemperatureItem
		uid: root.bindPrefix + "/Alarms/LowTemperature"
	}
	VeQuickItem {
		id: highStarterVoltageItem
		uid: root.bindPrefix + "/Alarms/HighStarterVoltage"
	}
	VeQuickItem {
		id: lowStarterVoltageItem
		uid: root.bindPrefix + "/Alarms/LowStarterVoltage"
	}
	VeQuickItem {
		id: highVoltageItem
		uid: root.bindPrefix + "/Alarms/HighVoltage"
	}
	VeQuickItem {
		id: lowVoltageItem
		uid: root.bindPrefix + "/Alarms/LowVoltage"
	}

	GradientListView {
		header: PrimaryListLabel {
			//% "No alarms"
			text: qsTrId("dcmeter_alarms_no_alarms")
			preferredVisible: !lowVoltageItem.valid
					 && !highVoltageItem.valid
					 && !lowStarterVoltageItem.valid
					 && !highStarterVoltageItem.valid
					 && !lowTemperatureItem.valid
					 && !highTemperatureItem.valid
		}

		model: DelegateComponentModel {
			DelegateComponent {
				preferredVisible: lowVoltageItem.valid
				ListAlarm {
					id: lowVoltage

					//% "Low voltage"
					text: qsTrId("dcmeter_alarms_low_voltage")
					dataItem.uid: root.bindPrefix + "/Alarms/LowVoltage"
				}
			}

			DelegateComponent {
				preferredVisible: highVoltageItem.valid
				ListAlarm {
					id: highVoltage

					//% "High voltage"
					text: qsTrId("dcmeter_alarms_high_voltage")
					dataItem.uid: root.bindPrefix + "/Alarms/HighVoltage"
				}
			}

			DelegateComponent {
				preferredVisible: lowStarterVoltageItem.valid
				ListAlarm {
					id: lowAuxVoltage

					//% "Low aux voltage"
					text: qsTrId("dcmeter_alarms_low_aux_voltage")
					dataItem.uid: root.bindPrefix + "/Alarms/LowStarterVoltage"
				}
			}

			DelegateComponent {
				preferredVisible: highStarterVoltageItem.valid
				ListAlarm {
					id: highAuxVoltage

					//% "High aux voltage"
					text: qsTrId("dcmeter_alarms_high_aux_voltage")
					dataItem.uid: root.bindPrefix + "/Alarms/HighStarterVoltage"
				}
			}

			DelegateComponent {
				preferredVisible: lowTemperatureItem.valid
				ListAlarm {
					id: lowTemp

					text: CommonWords.low_temperature
					dataItem.uid: root.bindPrefix + "/Alarms/LowTemperature"
				}
			}

			DelegateComponent {
				preferredVisible: highTemperatureItem.valid
				ListAlarm {
					id: highTemp

					text: CommonWords.high_temperature
					dataItem.uid: root.bindPrefix + "/Alarms/HighTemperature"
				}
			}
		}
	}
}
