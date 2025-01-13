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
				allowed: dataItem.isValid
				unit: VenusOS.Units_Volt_DC
			}

			ListQuantity {
				text: CommonWords.maximum_voltage
				dataItem.uid: root.bindPrefix + "/History/MaximumVoltage"
				allowed: dataItem.isValid
				unit: VenusOS.Units_Volt_DC
			}

			ListText {
				text: CommonWords.low_voltage_alarms
				dataItem.uid: root.bindPrefix + "/History/LowVoltageAlarms"
				allowed: dataItem.isValid
			}

			ListText {
				text: CommonWords.high_voltage_alarms
				dataItem.uid: root.bindPrefix + "/History/HighVoltageAlarms"
				allowed: dataItem.isValid
			}

			ListText {
				//% "Low aux voltage alarms"
				text: qsTrId("dcmeter_history_low_aux_voltage_alarms")
				dataItem.uid: visible ? root.bindPrefix + "/History/LowStarterVoltageAlarms" : ""
				allowed: root.showStarterVoltage
			}

			ListText {
				//% "High aux voltage alarms"
				text: qsTrId("dcmeter_history_high_aux_voltage_alarms")
				dataItem.uid: visible ? root.bindPrefix + "/History/HighStarterVoltageAlarms" : ""
				allowed: root.showStarterVoltage
			}

			ListQuantity {
				//% "Minimum aux voltage"
				text: qsTrId("dcmeter_history_minimum_aux_voltage")
				dataItem.uid: visible ? root.bindPrefix + "/History/MinimumStarterVoltage" : ""
				allowed: root.showStarterVoltage
				unit: VenusOS.Units_Volt_DC
			}

			ListQuantity {
				//% "Maximum aux voltage"
				text: qsTrId("dcmeter_history_maximum_aux_voltage")
				dataItem.uid: visible ? root.bindPrefix + "/History/MaximumStarterVoltage" : ""
				allowed: root.showStarterVoltage
				unit: VenusOS.Units_Volt_DC
			}

			ListTemperature {
				text: CommonWords.minimum_temperature
				allowed: showTemperature
				dataItem.uid: root.bindPrefix + "/History/MinimumTemperature"
			}

			ListTemperature {
				text: CommonWords.maximum_temperature
				allowed: showTemperature
				dataItem.uid: root.bindPrefix + "/History/MaximumTemperature"
			}

			ListQuantity {
				//% "Produced energy"
				text: qsTrId("dcmeter_history_produced_energy")
				dataItem.uid: root.bindPrefix + "/History/EnergyOut"
				allowed: dataItem.isValid
				unit: VenusOS.Units_Energy_KiloWattHour
			}

			ListQuantity {
				//% "Consumed energy"
				text: qsTrId("dcmeter_history_consumed_energy")
				dataItem.uid: root.bindPrefix + "/History/EnergyIn"
				allowed: dataItem.isValid
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
