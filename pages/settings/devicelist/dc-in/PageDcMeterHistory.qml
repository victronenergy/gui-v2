/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

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
			ListQuantityItem {
				text: CommonWords.minimum_voltage
				dataItem.uid: root.bindPrefix + "/History/MinimumVoltage"
				visible: defaultVisible && dataItem.isValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				text: CommonWords.maximum_voltage
				dataItem.uid: root.bindPrefix + "/History/MaximumVoltage"
				visible: defaultVisible && dataItem.isValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListTextItem {
				text: CommonWords.low_voltage_alarms
				dataItem.uid: root.bindPrefix + "/History/LowVoltageAlarms"
				visible: defaultVisible && dataItem.isValid
			}

			ListTextItem {
				text: CommonWords.high_voltage_alarms
				dataItem.uid: root.bindPrefix + "/History/HighVoltageAlarms"
				visible: defaultVisible && dataItem.isValid
			}

			ListTextItem {
				//% "Low aux voltage alarms"
				text: qsTrId("dcmeter_history_low_aux_voltage_alarms")
				dataItem.uid: visible ? root.bindPrefix + "/History/LowStarterVoltageAlarms" : ""
				visible: defaultVisible && root.showStarterVoltage
			}

			ListTextItem {
				//% "High aux voltage alarms"
				text: qsTrId("dcmeter_history_high_aux_voltage_alarms")
				dataItem.uid: visible ? root.bindPrefix + "/History/HighStarterVoltageAlarms" : ""
				visible: defaultVisible && root.showStarterVoltage
			}

			ListQuantityItem {
				//% "Minimum aux voltage"
				text: qsTrId("dcmeter_history_minimum_aux_voltage")
				dataItem.uid: visible ? root.bindPrefix + "/History/MinimumStarterVoltage" : ""
				visible: defaultVisible && root.showStarterVoltage
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				//% "Maximum aux voltage"
				text: qsTrId("dcmeter_history_maximum_aux_voltage")
				dataItem.uid: visible ? root.bindPrefix + "/History/MaximumStarterVoltage" : ""
				visible: defaultVisible && root.showStarterVoltage
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				text: CommonWords.minimum_temperature
				visible: defaultVisible && showTemperature
				dataItem.uid: root.bindPrefix + "/History/MinimumTemperature"
				unit: Global.systemSettings.temperatureUnit.value
			}

			ListQuantityItem {
				text: CommonWords.maximum_temperature
				visible: defaultVisible && showTemperature
				dataItem.uid: root.bindPrefix + "/History/MaximumTemperature"
				unit: Global.systemSettings.temperatureUnit.value
			}

			ListQuantityItem {
				//% "Produced energy"
				text: qsTrId("dcmeter_history_produced_energy")
				dataItem.uid: root.bindPrefix + "/History/EnergyOut"
				visible: defaultVisible && dataItem.isValid
				unit: VenusOS.Units_Energy_KiloWattHour
			}

			ListQuantityItem {
				//% "Consumed energy"
				text: qsTrId("dcmeter_history_consumed_energy")
				dataItem.uid: root.bindPrefix + "/History/EnergyIn"
				visible: defaultVisible && dataItem.isValid
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
