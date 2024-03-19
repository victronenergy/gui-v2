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
		model: ObjectModel {
			ListQuantityItem {
				//% "Deepest discharge"
				text: qsTrId("batteryalarms_deepest_discharge")
				dataItem.uid: root.bindPrefix + "/History/DeepestDischarge"
				allowed: defaultAllowed && dataItem.isValid
				unit: VenusOS.Units_AmpHour
			}

			ListQuantityItem {
				//% "Last discharge"
				text: qsTrId("batteryhistory_last_discharge")
				dataItem.uid: root.bindPrefix + "/History/LastDischarge"
				allowed: defaultAllowed && dataItem.isValid
				unit: VenusOS.Units_AmpHour
			}

			ListQuantityItem {
				//% "Average discharge"
				text: qsTrId("batteryhistory_average_discharge")
				dataItem.uid: root.bindPrefix + "/History/AverageDischarge"
				allowed: defaultAllowed && dataItem.isValid
				unit: VenusOS.Units_AmpHour
			}

			ListTextItem {
				//% "Total charge cycles"
				text: qsTrId("batteryhistory_total_charge_cycles")
				dataItem.uid: root.bindPrefix + "/History/ChargeCycles"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTextItem {
				//% "Number of full discharges"
				text: qsTrId("batteryhistory_number_of_full_discharges")
				dataItem.uid: root.bindPrefix + "/History/FullDischarges"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListQuantityItem {
				//% "Cumulative Ah drawn"
				text: qsTrId("batteryhistory_cumulative_ah_drawn")
				dataItem.uid: root.bindPrefix + "/History/TotalAhDrawn"
				allowed: defaultAllowed && dataItem.isValid
				unit: VenusOS.Units_AmpHour
			}

			ListQuantityItem {
				text: CommonWords.minimum_voltage
				dataItem.uid: root.bindPrefix + "/History/MinimumVoltage"
				allowed: defaultAllowed && dataItem.isValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				text: CommonWords.maximum_voltage
				dataItem.uid: root.bindPrefix + "/History/MaximumVoltage"
				allowed: defaultAllowed && dataItem.isValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				//% "Minimum cell voltage"
				text: qsTrId("batteryhistory_minimum_cell_voltage")
				dataItem.uid: root.bindPrefix + "/History/MinimumCellVoltage"
				allowed: defaultAllowed && dataItem.isValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				//% "Maximum cell voltage"
				text: qsTrId("batteryhistory_maximum_cell_voltage")
				dataItem.uid: root.bindPrefix + "/History/MaximumCellVoltage"
				allowed: defaultAllowed && dataItem.isValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListTextItem {
				//% "Time since last full charge"
				text: qsTrId("batteryhistory_time_since_last_full_charge")
				dataItem.uid: root.bindPrefix + "/History/TimeSinceLastFullCharge"
				allowed: defaultAllowed && dataItem.isValid
				secondaryText: Utils.secondsToString(dataItem.value)
			}

			ListTextItem {
				//% "Synchronisation count"
				text: qsTrId("batteryhistory_synchronisation_count")
				dataItem.uid: root.bindPrefix + "/History/AutomaticSyncs"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTextItem {
				text: CommonWords.low_voltage_alarms
				dataItem.uid: root.bindPrefix + "/History/LowVoltageAlarms"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTextItem {
				text: CommonWords.high_voltage_alarms
				dataItem.uid: root.bindPrefix + "/History/HighVoltageAlarms"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTextItem {
				id: lowStarterVoltageAlarm

				//% "Low starter battery voltage alarms"
				text: qsTrId("batteryhistory_low_starter_bat_voltage_alarms")
				dataItem.uid: visible ? root.bindPrefix + "/History/LowStarterVoltageAlarms" : ""
				allowed: defaultAllowed && hasStarterVoltage.isValid && hasStarterVoltage.value

				VeQuickItem {
					id: hasStarterVoltage
					uid: root.bindPrefix + "/Settings/HasStarterVoltage"
				}
			}

			ListTextItem {
				//% "High starter batttery voltage alarms"
				text: qsTrId("batteryhistory_high_starter_bat_voltage_alarms")
				dataItem.uid: visible ? root.bindPrefix + "/History/HighStarterVoltageAlarms" : ""
				allowed: defaultAllowed && lowStarterVoltageAlarm.visible
			}

			ListQuantityItem {
				//% "Minimum starter battery voltage"
				text: qsTrId("batteryhistory_minimum_starter_bat_voltage")
				dataItem.uid: visible ? root.bindPrefix + "/History/MinimumStarterVoltage" : ""
				allowed: defaultAllowed && lowStarterVoltageAlarm.visible
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				//% "Maximum starter battery voltage"
				text: qsTrId("batteryhistory_maximum_starter_bat_voltage")
				dataItem.uid: visible ? root.bindPrefix + "/History/MaximumStarterVoltage" : ""
				allowed: defaultAllowed && lowStarterVoltageAlarm.visible
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListTemperatureItem {
				text: CommonWords.minimum_temperature
				allowed: defaultAllowed && hasTemperature.value === 1 && dataItem.isValid
				dataItem.uid: root.bindPrefix + "/History/MinimumTemperature"

				VeQuickItem {
					id: hasTemperature
					uid: root.bindPrefix + "/Settings/HasTemperature"
				}
			}

			ListTemperatureItem {
				text: CommonWords.maximum_temperature
				allowed: defaultAllowed && hasTemperature.value === 1 && dataItem.isValid
				dataItem.uid: root.bindPrefix + "/History/MaximumTemperature"
			}

			ListQuantityItem {
				//% "Discharged energy"
				text: qsTrId("batteryhistory_discharged_energy")
				dataItem.uid: root.bindPrefix + "/History/DischargedEnergy"
				allowed: defaultAllowed && dataItem.isValid
				unit: VenusOS.Units_Energy_KiloWattHour
			}

			ListQuantityItem {
				//% "Charged energy"
				text: qsTrId("batteryhistory_charged_energy")
				dataItem.uid: root.bindPrefix + "/History/ChargedEnergy"
				allowed: defaultAllowed && dataItem.isValid
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
