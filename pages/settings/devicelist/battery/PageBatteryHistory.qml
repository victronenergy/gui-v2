/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

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
				//% "Minimum voltage"
				text: qsTrId("batteryhistory_minimum_voltage")
				dataSource: root.bindPrefix + "/History/MinimumVoltage"
				visible: defaultVisible && dataValid
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				//% "Maximum voltage"
				text: qsTrId("batteryhistory_maximum_voltage")
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
				//% "Low voltage alarms"
				text: qsTrId("batteryhistory_low_voltage_alarms")
				dataSource: root.bindPrefix + "/History/LowVoltageAlarms"
				visible: defaultVisible && dataValid
			}

			ListTextItem {
				//% "High voltage alarms"
				text: qsTrId("batteryhistory_high_voltage_alarms")
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
				//% "Minimum temperature"
				text: qsTrId("batteryhistory_minimum_temperature")
				visible: defaultVisible && hasTemperature.value === 1 && dataValid
				dataSource: root.bindPrefix + "/History/MinimumTemperature"
				unit: Global.systemSettings.temperatureUnit.value

				DataPoint {
					id: hasTemperature
					source: root.bindPrefix + "/Settings/HasTemperature"
				}
			}

			ListQuantityItem {
				//% "Maximum temperature"
				text: qsTrId("batteryhistory_maximum_temperature")
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

			ListLabel {
				//% "Info: Reset history on the monitor itself"
				text: qsTrId("batteryhistory_info_reset_history_on_the_monitor_itself")
				visible: !clearHistory.visible
				horizontalAlignment: Text.AlignHCenter
			}

			ListButton {
				id: clearHistory

				//% "Clear History"
				text: qsTrId("batteryhistory_clear_history")
				secondaryText: enabled
					   ? CommonWords.press_to_clear
						 //% "Clearing"
					   : qsTrId("batteryhistory_clearing")

				DataPoint {
					id: clear
					source: root.bindPrefix + "/History/Clear"
				}

				DataPoint {
					id: canBeCleared
					source: root.bindPrefix + "/History/CanBeCleared"
				}

				DataPoint {
					id: connected
					source: root.bindPrefix + "/Connected"
				}

				Timer {
					id: timer
					interval: 2000
				}
				enabled: !timer.running

				onClicked: {
					/*
					 * Write some value to the item as the clear command does not need
					 * to have a value. Do make sure to only write the value when the
					 * button is pressed and not when released.
					 */
					clear.setValue(1)
					timer.start()
				}

				visible: connected.value === 1 && canBeCleared.value === 1
			}
		}
	}
}
