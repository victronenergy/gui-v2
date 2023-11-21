/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListQuantityItem {
				//% "Deepest discharge"
				text: qsTrId("batteryalarms_deepest_discharge")
				dataSource: root.bindPrefix + "/History/DeepestDischarge"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_AmpHour
			}

			ListQuantityItem {
				//% "Last discharge"
				text: qsTrId("batteryhistory_last_discharge")
				dataSource: root.bindPrefix + "/History/LastDischarge"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_AmpHour
			}

			ListQuantityItem {
				//% "Average discharge"
				text: qsTrId("batteryhistory_average_discharge")
				dataSource: root.bindPrefix + "/History/AverageDischarge"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_AmpHour
			}

			ListTextItem {
				//% "Total charge cycles"
				text: qsTrId("batteryhistory_total_charge_cycles")
				dataSource: root.bindPrefix + "/History/ChargeCycles"
				visible: defaultVisible && dataValid
			}

			ListTextItem {
				//% "Number of full discharges"
				text: qsTrId("batteryhistory_number_of_full_discharges")
				dataSource: root.bindPrefix + "/History/FullDischarges"
				visible: defaultVisible && dataValid
			}

			ListQuantityItem {
				//% "Cumulative Ah drawn"
				text: qsTrId("batteryhistory_cumulative_ah_drawn")
				dataSource: root.bindPrefix + "/History/TotalAhDrawn"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_AmpHour
			}

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

			ListQuantityItem {
				//% "Minimum cell voltage"
				text: qsTrId("batteryhistory_minimum_cell_voltage")
				dataSource: root.bindPrefix + "/History/MinimumCellVoltage"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				//% "Maximum cell voltage"
				text: qsTrId("batteryhistory_maximum_cell_voltage")
				dataSource: root.bindPrefix + "/History/MaximumCellVoltage"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListTextItem {
				//% "Time since last full charge"
				text: qsTrId("batteryhistory_time_since_last_full_charge")
				dataSource: root.bindPrefix + "/History/TimeSinceLastFullCharge"
				visible: defaultVisible && dataValid
				secondaryText: Utils.secondsToString(dataValue)
			}

			ListTextItem {
				//% "Synchronisation count"
				text: qsTrId("batteryhistory_synchronisation_count")
				dataSource: root.bindPrefix + "/History/AutomaticSyncs"
				visible: defaultVisible && dataValid
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
				id: lowStarterVoltageAlarm

				//% "Low starter battery voltage alarms"
				text: qsTrId("batteryhistory_low_starter_bat_voltage_alarms")
				dataSource: visible ? root.bindPrefix + "/History/LowStarterVoltageAlarms" : ""
				visible: defaultVisible && hasStarterVoltage.valid && hasStarterVoltage.value

				DataPoint {
					id: hasStarterVoltage
					source: root.bindPrefix + "/Settings/HasStarterVoltage"
				}
			}

			ListTextItem {
				//% "High starter batttery voltage alarms"
				text: qsTrId("batteryhistory_high_starter_bat_voltage_alarms")
				dataSource: visible ? root.bindPrefix + "/History/HighStarterVoltageAlarms" : ""
				visible: defaultVisible && lowStarterVoltageAlarm.visible
			}

			ListQuantityItem {
				//% "Minimum starter battery voltage"
				text: qsTrId("batteryhistory_minimum_starter_bat_voltage")
				dataSource: visible ? root.bindPrefix + "/History/MinimumStarterVoltage" : ""
				visible: defaultVisible && lowStarterVoltageAlarm.visible
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				//% "Maximum starter battery voltage"
				text: qsTrId("batteryhistory_maximum_starter_bat_voltage")
				dataSource: visible ? root.bindPrefix + "/History/MaximumStarterVoltage" : ""
				visible: defaultVisible && lowStarterVoltageAlarm.visible
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				text: CommonWords.minimum_temperature
				visible: defaultVisible && hasTemperature.value === 1 && dataValid
				dataSource: root.bindPrefix + "/History/MinimumTemperature"
				unit: Global.systemSettings.temperatureUnit.value

				DataPoint {
					id: hasTemperature
					source: root.bindPrefix + "/Settings/HasTemperature"
				}
			}

			ListQuantityItem {
				text: CommonWords.maximum_temperature
				visible: defaultVisible && hasTemperature.value === 1 && dataValid
				dataSource: root.bindPrefix + "/History/MaximumTemperature"
				unit: Global.systemSettings.temperatureUnit.value
			}

			ListQuantityItem {
				//% "Discharged energy"
				text: qsTrId("batteryhistory_discharged_energy")
				dataSource: root.bindPrefix + "/History/DischargedEnergy"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Energy_KiloWattHour
			}

			ListQuantityItem {
				//% "Charged energy"
				text: qsTrId("batteryhistory_charged_energy")
				dataSource: root.bindPrefix + "/History/ChargedEnergy"
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
