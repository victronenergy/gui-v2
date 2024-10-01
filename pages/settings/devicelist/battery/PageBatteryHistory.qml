/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix
	required property BatteryHistory history

	GradientListView {
		model: ObjectModel {
			ListQuantityItem {
				//% "Deepest discharge"
				text: qsTrId("batteryalarms_deepest_discharge")
				allowed: defaultAllowed && root.history.allowsDeepestDischarge
				unit: VenusOS.Units_AmpHour
				value: allowed ? root.history.deepestDischarge.value : NaN
			}

			ListQuantityItem {
				//% "Last discharge"
				text: qsTrId("batteryhistory_last_discharge")
				allowed: defaultAllowed && root.history.allowsLastDischarge
				unit: VenusOS.Units_AmpHour
				value: allowed ? root.history.lastDischarge.value : NaN
			}

			ListQuantityItem {
				//% "Average discharge"
				text: qsTrId("batteryhistory_average_discharge")
				allowed: defaultAllowed && root.history.allowsAverageDischarge
				unit: VenusOS.Units_AmpHour
				value: allowed ? root.history.averageDischarge.value : NaN
			}

			ListTextItem {
				//% "Total charge cycles"
				text: qsTrId("batteryhistory_total_charge_cycles")
				allowed: defaultAllowed && root.history.allowsChargeCycles
				secondaryText: allowed ? root.history.chargeCycles.value : ""
			}

			ListTextItem {
				//% "Number of full discharges"
				text: qsTrId("batteryhistory_number_of_full_discharges")
				allowed: defaultAllowed && root.history.allowsFullDischarges
				secondaryText: allowed ? root.history.fullDischarges.value : ""
			}

			ListQuantityItem {
				//% "Cumulative Ah drawn"
				text: qsTrId("batteryhistory_cumulative_ah_drawn")
				allowed: defaultAllowed && root.history.allowsTotalAhDrawn
				unit: VenusOS.Units_AmpHour
				value: allowed ? root.history.totalAhDrawn.value : NaN
			}

			ListQuantityItem {
				text: CommonWords.minimum_voltage
				allowed: defaultAllowed && root.history.allowsMinimumVoltage
				unit: VenusOS.Units_Volt_DC
				value: allowed ? root.history.minimumVoltage.value : NaN
			}

			ListQuantityItem {
				text: CommonWords.maximum_voltage
				allowed: defaultAllowed && root.history.allowsMaximumVoltage
				unit: VenusOS.Units_Volt_DC
				value: allowed ? root.history.maximumVoltage.value : NaN
			}

			ListQuantityItem {
				//% "Minimum cell voltage"
				text: qsTrId("batteryhistory_minimum_cell_voltage")
				allowed: defaultAllowed && root.history.allowsMinimumCellVoltage
				unit: VenusOS.Units_Volt_DC
				value: allowed ? root.history.minimumCellVoltage.value : NaN
				precision: 3
			}

			ListQuantityItem {
				//% "Maximum cell voltage"
				text: qsTrId("batteryhistory_maximum_cell_voltage")
				allowed: defaultAllowed && root.history.allowsMaximumCellVoltage
				unit: VenusOS.Units_Volt_DC
				value: allowed ? root.history.maximumCellVoltage.value : NaN
				precision: 3
			}

			ListTextItem {
				//% "Time since last full charge"
				text: qsTrId("batteryhistory_time_since_last_full_charge")
				allowed: defaultAllowed && root.history.allowsTimeSinceLastFullCharge
				secondaryText: allowed ? Utils.secondsToString(root.history.timeSinceLastFullCharge.value) : ""
			}

			ListTextItem {
				//% "Synchronisation count"
				text: qsTrId("batteryhistory_synchronisation_count")
				allowed: defaultAllowed && root.history.allowsAutomaticSyncs
				secondaryText: allowed ? root.history.automaticSyncs.value : ""
			}

			ListTextItem {
				text: CommonWords.low_voltage_alarms
				allowed: defaultAllowed && root.history.allowsLowVoltageAlarms
				secondaryText: allowed ? root.history.lowVoltageAlarms.value : ""
			}

			ListTextItem {
				text: CommonWords.high_voltage_alarms
				allowed: defaultAllowed && root.history.allowsHighVoltageAlarms
				secondaryText: allowed ? root.history.highVoltageAlarms.value : ""
			}

			ListTextItem {
				//% "Low starter battery voltage alarms"
				text: qsTrId("batteryhistory_low_starter_bat_voltage_alarms")
				allowed: defaultAllowed && root.history.allowsLowStarterVoltageAlarms
				secondaryText: allowed ? root.history.lowStarterVoltageAlarms.value : ""
			}

			ListTextItem {
				//% "High starter battery voltage alarms"
				text: qsTrId("batteryhistory_high_starter_bat_voltage_alarms")
				allowed: defaultAllowed && root.history.allowsHighStarterVoltageAlarms
				secondaryText: allowed ? root.history.highStarterVoltageAlarms.value : ""
			}

			ListQuantityItem {
				//% "Minimum starter battery voltage"
				text: qsTrId("batteryhistory_minimum_starter_bat_voltage")
				allowed: defaultAllowed && root.history.allowsMinimumStarterVoltage
				value: allowed ? root.history.minimumStarterVoltage.value : NaN
				unit: VenusOS.Units_Volt_DC
			}

			ListQuantityItem {
				//% "Maximum starter battery voltage"
				text: qsTrId("batteryhistory_maximum_starter_bat_voltage")
				allowed: defaultAllowed && root.history.allowsMaximumStarterVoltage
				value: allowed ? root.history.maximumStarterVoltage.value : NaN
				unit: VenusOS.Units_Volt_DC
			}

			ListTemperatureItem {
				text: CommonWords.minimum_temperature
				allowed: defaultAllowed && root.history.allowsMinimumTemperature
				value: allowed ? root.history.minimumTemperature.value : NaN
			}

			ListTemperatureItem {
				text: CommonWords.maximum_temperature
				allowed: defaultAllowed && root.history.allowsMaximumTemperature
				value: allowed ? root.history.maximumTemperature.value : NaN
			}

			ListQuantityItem {
				//% "Discharged energy"
				text: qsTrId("batteryhistory_discharged_energy")
				allowed: defaultAllowed && root.history.allowsDischargedEnergy
				unit: VenusOS.Units_Energy_KiloWattHour
				value: allowed ? root.history.dischargedEnergy.value : NaN
			}

			ListQuantityItem {
				//% "Charged energy"
				text: qsTrId("batteryhistory_charged_energy")
				allowed: defaultAllowed && root.history.allowsChargedEnergy
				unit: VenusOS.Units_Energy_KiloWattHour
				value: allowed ? root.history.chargedEnergy.value : NaN
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
