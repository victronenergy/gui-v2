/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	readonly property bool showStarterVoltage: hasStarterVoltage.isValid && hasStarterVoltage.value
	readonly property bool showTemperature: hasTemperature.isValid && hasTemperature.value

	VeQuickItem {
		id: hasStarterVoltage
		uid: root.bindPrefix + "/Settings/HasStarterVoltage"
	}

	VeQuickItem {
		id: hasTemperature
		uid: root.bindPrefix + "/Settings/HasTemperature"
	}

	GradientListView {
		model: ObjectModel {
			ListQuantity {
				text: CommonWords.minimum_voltage
				dataItem.uid: root.bindPrefix + "/History/MinimumVoltage"
				preferredVisible: dataItem.isValid
				unit: VenusOS.Units_Volt_DC
			}

			ListQuantity {
				text: CommonWords.maximum_voltage
				dataItem.uid: root.bindPrefix + "/History/MaximumVoltage"
				preferredVisible: dataItem.isValid
				unit: VenusOS.Units_Volt_DC
			}

			ListText {
				text: CommonWords.low_voltage_alarms
				dataItem.uid: root.bindPrefix + "/History/LowVoltageAlarms"
				preferredVisible: dataItem.isValid
			}

			ListText {
				text: CommonWords.high_voltage_alarms
				dataItem.uid: root.bindPrefix + "/History/HighVoltageAlarms"
				preferredVisible: dataItem.isValid
			}

			ListText {
				//% "Low aux voltage alarms"
				text: qsTrId("dcmeter_history_low_aux_voltage_alarms")
				dataItem.uid: visible ? root.bindPrefix + "/History/LowStarterVoltageAlarms" : ""
				preferredVisible: root.showStarterVoltage
			}

			ListText {
				//% "High aux voltage alarms"
				text: qsTrId("dcmeter_history_high_aux_voltage_alarms")
				dataItem.uid: visible ? root.bindPrefix + "/History/HighStarterVoltageAlarms" : ""
				preferredVisible: root.showStarterVoltage
			}

			ListQuantity {
				//% "Minimum aux voltage"
				text: qsTrId("dcmeter_history_minimum_aux_voltage")
				dataItem.uid: visible ? root.bindPrefix + "/History/MinimumStarterVoltage" : ""
				preferredVisible: root.showStarterVoltage
				unit: VenusOS.Units_Volt_DC
			}

			ListQuantity {
				//% "Maximum aux voltage"
				text: qsTrId("dcmeter_history_maximum_aux_voltage")
				dataItem.uid: visible ? root.bindPrefix + "/History/MaximumStarterVoltage" : ""
				preferredVisible: root.showStarterVoltage
				unit: VenusOS.Units_Volt_DC
			}

			ListTemperature {
				text: CommonWords.minimum_temperature
				preferredVisible: showTemperature
				dataItem.uid: root.bindPrefix + "/History/MinimumTemperature"
			}

			ListTemperature {
				text: CommonWords.maximum_temperature
				preferredVisible: showTemperature
				dataItem.uid: root.bindPrefix + "/History/MaximumTemperature"
			}

			ListQuantity {
				//% "Produced energy"
				text: qsTrId("dcmeter_history_produced_energy")
				dataItem.uid: root.bindPrefix + "/History/EnergyOut"
				preferredVisible: dataItem.isValid
				unit: VenusOS.Units_Energy_KiloWattHour
			}

			ListQuantity {
				//% "Consumed energy"
				text: qsTrId("dcmeter_history_consumed_energy")
				dataItem.uid: root.bindPrefix + "/History/EnergyIn"
				preferredVisible: dataItem.isValid
				unit: VenusOS.Units_Energy_KiloWattHour
			}

			ListResetHistory {
				visible: !clearHistory.visible
			}

			ListClearHistoryButton {
				id: clearHistory
				bindPrefix: root.bindPrefix
			}
		}
	}
}
