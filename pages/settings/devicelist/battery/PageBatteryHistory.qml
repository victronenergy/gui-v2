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
		model: DelegateComponentModel {
			DelegateComponent {
				preferredVisible: root.history.allowsDeepestDischarge
				ListQuantity {
					//% "Deepest discharge"
					text: qsTrId("batteryalarms_deepest_discharge")
					unit: VenusOS.Units_AmpHour
					value: preferredVisible ? root.history.deepestDischarge.value : NaN
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsLastDischarge
				ListQuantity {
					//% "Last discharge"
					text: qsTrId("batteryhistory_last_discharge")
					unit: VenusOS.Units_AmpHour
					value: preferredVisible ? root.history.lastDischarge.value : NaN
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsAverageDischarge
				ListQuantity {
					//% "Average discharge"
					text: qsTrId("batteryhistory_average_discharge")
					unit: VenusOS.Units_AmpHour
					value: preferredVisible ? root.history.averageDischarge.value : NaN
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsChargeCycles
				ListText {
					//% "Total charge cycles"
					text: qsTrId("batteryhistory_total_charge_cycles")
					secondaryText: preferredVisible ? root.history.chargeCycles.value : ""
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsFullDischarges
				ListText {
					//% "Number of full discharges"
					text: qsTrId("batteryhistory_number_of_full_discharges")
					secondaryText: preferredVisible ? root.history.fullDischarges.value : ""
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsTotalAhDrawn
				ListQuantity {
					//% "Cumulative Ah drawn"
					text: qsTrId("batteryhistory_cumulative_ah_drawn")
					unit: VenusOS.Units_AmpHour
					value: preferredVisible ? root.history.totalAhDrawn.value : NaN
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsMinimumVoltage
				ListQuantity {
					text: CommonWords.minimum_voltage
					unit: VenusOS.Units_Volt_DC
					value: preferredVisible ? root.history.minimumVoltage.value : NaN
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsMaximumVoltage
				ListQuantity {
					text: CommonWords.maximum_voltage
					unit: VenusOS.Units_Volt_DC
					value: preferredVisible ? root.history.maximumVoltage.value : NaN
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsMinimumCellVoltage
				ListQuantity {
					//% "Minimum cell voltage"
					text: qsTrId("batteryhistory_minimum_cell_voltage")
					unit: VenusOS.Units_Volt_DC
					value: preferredVisible ? root.history.minimumCellVoltage.value : NaN
					decimals: 3
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsMaximumCellVoltage
				ListQuantity {
					//% "Maximum cell voltage"
					text: qsTrId("batteryhistory_maximum_cell_voltage")
					unit: VenusOS.Units_Volt_DC
					value: preferredVisible ? root.history.maximumCellVoltage.value : NaN
					decimals: 3
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsTimeSinceLastFullCharge
				ListText {
					//% "Time since last full charge"
					text: qsTrId("batteryhistory_time_since_last_full_charge")
					secondaryText: preferredVisible ? Utils.secondsToString(root.history.timeSinceLastFullCharge.value) : ""
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsAutomaticSyncs
				ListText {
					//% "Synchronisation count"
					text: qsTrId("batteryhistory_synchronisation_count")
					secondaryText: preferredVisible ? root.history.automaticSyncs.value : ""
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsLowVoltageAlarms
				ListText {
					text: CommonWords.low_voltage_alarms
					secondaryText: preferredVisible ? root.history.lowVoltageAlarms.value : ""
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsHighVoltageAlarms
				ListText {
					text: CommonWords.high_voltage_alarms
					secondaryText: preferredVisible ? root.history.highVoltageAlarms.value : ""
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsLowStarterVoltageAlarms
				ListText {
					//% "Low starter battery voltage alarms"
					text: qsTrId("batteryhistory_low_starter_bat_voltage_alarms")
					secondaryText: preferredVisible ? root.history.lowStarterVoltageAlarms.value : ""
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsHighStarterVoltageAlarms
				ListText {
					//% "High starter battery voltage alarms"
					text: qsTrId("batteryhistory_high_starter_bat_voltage_alarms")
					secondaryText: preferredVisible ? root.history.highStarterVoltageAlarms.value : ""
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsMinimumStarterVoltage
				ListQuantity {
					//% "Minimum starter battery voltage"
					text: qsTrId("batteryhistory_minimum_starter_bat_voltage")
					value: preferredVisible ? root.history.minimumStarterVoltage.value : NaN
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsMaximumStarterVoltage
				ListQuantity {
					//% "Maximum starter battery voltage"
					text: qsTrId("batteryhistory_maximum_starter_bat_voltage")
					value: preferredVisible ? root.history.maximumStarterVoltage.value : NaN
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsMinimumTemperature
				ListTemperature {
					text: CommonWords.minimum_temperature
					value: preferredVisible ? root.history.minimumTemperature.value : NaN
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsMaximumTemperature
				ListTemperature {
					text: CommonWords.maximum_temperature
					value: preferredVisible ? root.history.maximumTemperature.value : NaN
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsDischargedEnergy
				ListQuantity {
					//% "Discharged energy"
					text: qsTrId("batteryhistory_discharged_energy")
					unit: VenusOS.Units_Energy_KiloWattHour
					value: preferredVisible ? root.history.dischargedEnergy.value : NaN
				}
			}

			DelegateComponent {
				preferredVisible: root.history.allowsChargedEnergy
				ListQuantity {
					//% "Charged energy"
					text: qsTrId("batteryhistory_charged_energy")
					unit: VenusOS.Units_Energy_KiloWattHour
					value: preferredVisible ? root.history.chargedEnergy.value : NaN
				}
			}

			DelegateComponent {
				ListInfoLabel {
					text: CommonWords.reset_history_on_the_monitor_itself
					visible: !clearHistoryDC.clearHistoryVisible
				}
			}

			DelegateComponent {
				id: clearHistoryDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/History/CanBeCleared" }
				property VeQuickItem connectedItem: VeQuickItem { uid: root.bindPrefix + "/Connected" }
				property bool clearHistoryVisible: connectedItem.value === 1 && dataItem.value === 1
				ListClearHistoryButton {
					bindPrefix: root.bindPrefix
				}
			}
		}
	}
}
