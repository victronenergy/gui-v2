/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SettingsColumn {
	id: root

	required property string bindPrefix

	preferredVisible: overallHistory.preferredVisible || chargeCycleHistory.preferredVisible

	ListNavigation {
		id: overallHistory

		text: CommonWords.overall_history
		preferredVisible: overallHistoryMonitor.hasVisibleItem
		onClicked: {
			Global.pageManager.pushPage(overallHistoryComponent, { "title": text })
		}

		// Declare ObjectModelMonitor before the model that it is monitoring. See QTBUG-123496
		ObjectModelMonitor {
			id: overallHistoryMonitor
			model: overallHistoryModel
		}

		VisibleItemModel {
			id: overallHistoryModel

			ListText {
				//% "Operation time"
				text: qsTrId("alternator_wakespeed_operation_time")
				secondaryText: Utils.secondsToString(dataItem.value, true)
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/OperationTime"
				preferredVisible: dataItem.valid
			}

			ListQuantity {
				//% "Charged Ah"
				text: qsTrId("alternator_wakespeed_charged_ah")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/ChargedAh"
				unit: VenusOS.Units_AmpHour
				precision: 0
				preferredVisible: dataItem.valid
			}

			ListText {
				//% "Cycles started"
				text: qsTrId("alternator_wakespeed_cycles_started")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/CyclesStarted"
				preferredVisible: dataItem.valid
			}

			ListText {
				//% "Cycles completed"
				text: qsTrId("alternator_wakespeed_cycles_completed")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/CyclesCompleted"
				preferredVisible: dataItem.valid
			}

			ListText {
				//% "Number of power-ups"
				text: qsTrId("alternator_wakespeed_nr_of_power_ups")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/NrOfPowerups"
				preferredVisible: dataItem.valid
			}

			ListText {
				//% "Number of deep discharges"
				text: qsTrId("alternator_wakespeed_nr_of_deep_discharges")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/NrOfDeepDischarges"
				preferredVisible: dataItem.valid
			}
		}

		Component {
			id: overallHistoryComponent

			Page {
				GradientListView {
					model: overallHistoryModel
				}
			}
		}
	}

	ListNavigation {
		id: chargeCycleHistory

		//% "Charge cycle history"
		text: qsTrId("alternator_wakespeed_charge_cycle_history")
		preferredVisible: historyCyclesAvailable.valid
		onClicked: {
			Global.pageManager.pushPage(chargeHistoryComponent, { "title": text })
		}

		Component {
			id: chargeHistoryComponent

			Page {
				GradientListView {
					model: historyCyclesAvailable.valid ? historyCyclesAvailable.value + 1 : 1
					delegate: Component {
						ListCycleHistoryItem {
							width: parent ? parent.width : 0
							bindPrefix: root.bindPrefix + "/History/Cycle/" + index
							cycle: index
						}
					}
				}
			}
		}

		VeQuickItem {
			id: historyCyclesAvailable
			uid: root.bindPrefix + "/History/Cycle/CyclesAvailable"
		}
	}
}
