/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property string bindPrefix

	readonly property bool showStarterVoltage: hasStarterVoltage.valid && hasStarterVoltage.value
	readonly property bool showTemperature: hasTemperature.valid && hasTemperature.value

	DataPoint {
		id: hasStarterVoltage
		source: root.bindPrefix + "/Settings/HasStarterVoltage"
	}

	DataPoint {
		id: hasTemperature
		source: root.bindPrefix + "/Settings/HasTemperature"
	}

	GradientListView {
		model: ObjectModel {
			ListQuantityItem {
				text: CommonWords.minimum_voltage
				dataSource: root.bindPrefix + "/History/MinimumVoltage"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				text: CommonWords.maximum_voltage
				dataSource: root.bindPrefix + "/History/MaximumVoltage"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListTextItem {
				text: CommonWords.low_voltage_alarms
				dataSource: root.bindPrefix + "/History/LowVoltageAlarms"
				visible: defaultVisible && dataValid
			}

			ListTextItem {
				text: CommonWords.high_voltage_alarms
				dataSource: root.bindPrefix + "/History/HighVoltageAlarms"
				visible: defaultVisible && dataValid
			}

			ListTextItem {
				//% "Low aux voltage alarms"
				text: qsTrId("dcmeter_history_low_aux_voltage_alarms")
				dataSource: visible ? root.bindPrefix + "/History/LowStarterVoltageAlarms" : ""
				visible: defaultVisible && root.showStarterVoltage
			}

			ListTextItem {
				//% "High aux voltage alarms"
				text: qsTrId("dcmeter_history_high_aux_voltage_alarms")
				dataSource: visible ? root.bindPrefix + "/History/HighStarterVoltageAlarms" : ""
				visible: defaultVisible && root.showStarterVoltage
			}

			ListQuantityItem {
				//% "Minimum aux voltage"
				text: qsTrId("dcmeter_history_minimum_aux_voltage")
				dataSource: visible ? root.bindPrefix + "/History/MinimumStarterVoltage" : ""
				visible: defaultVisible && root.showStarterVoltage
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				//% "Maximum aux voltage"
				text: qsTrId("dcmeter_history_maximum_aux_voltage")
				dataSource: visible ? root.bindPrefix + "/History/MaximumStarterVoltage" : ""
				visible: defaultVisible && root.showStarterVoltage
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				text: CommonWords.minimum_temperature
				visible: defaultVisible && showTemperature
				dataSource: root.bindPrefix + "/History/MinimumTemperature"
				unit: Global.systemSettings.temperatureUnit.value
			}

			ListQuantityItem {
				text: CommonWords.maximum_temperature
				visible: defaultVisible && showTemperature
				dataSource: root.bindPrefix + "/History/MaximumTemperature"
				unit: Global.systemSettings.temperatureUnit.value
			}

			ListQuantityItem {
				//% "Produced energy"
				text: qsTrId("dcmeter_history_produced_energy")
				dataSource: root.bindPrefix + "/History/EnergyOut"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Energy_KiloWattHour
			}

			ListQuantityItem {
				//% "Consumed energy"
				text: qsTrId("dcmeter_history_consumed_energy")
				dataSource: root.bindPrefix + "/History/EnergyIn"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Energy_KiloWattHour
			}

			ListResetHistoryLabel {
				visible: !clearHistory.visible
			}

			ListClearHistoryButton {
				id: clearHistory
				bindPrefix: root.bindPrefix
			}
		}
	}
}
