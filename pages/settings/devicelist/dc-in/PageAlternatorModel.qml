/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ObjectModel {
	id: root

	property string bindPrefix

	ListSwitch {
		text: CommonWords.switch_mode
		dataItem.uid: root.bindPrefix + "/Mode"
		valueTrue: 1
		valueFalse: 4
		preferredVisible: dataItem.isValid
	}

	ListDcInputQuantityGroup {
		bindPrefix: root.bindPrefix
	}

	ListDcOutputQuantityGroup {
		bindPrefix: root.bindPrefix
	}

	ListTemperature {
		//% "Alternator Temperature"
		text: qsTrId("alternator_temperature")
		dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
		preferredVisible: dataItem.isValid
	}

	ListText {
		text: CommonWords.state
		secondaryText: Global.system.systemStateToText(dataItem.value)
		preferredVisible: dataItem.isValid
		dataItem.uid: root.bindPrefix + "/State"
	}

	ListText {
		text: CommonWords.network_status
		secondaryText: Global.systemSettings.networkStatusToText(dataItem.value)
		dataItem.uid: root.bindPrefix + "/Link/NetworkStatus"
		preferredVisible: dataItem.isValid
	}

	ListText {
		text: CommonWords.error
		dataItem.uid: root.bindPrefix + "/ErrorCode"
		preferredVisible: dataItem.isValid
		secondaryText: dataItem.isValid ? ChargerError.description(dataItem.value) : dataItem.invalidText
	}

	ListText {
		text: CommonWords.error
		dataItem.uid: root.bindPrefix + "/Error/0/Id"
		preferredVisible: dataItem.isValid
		secondaryText: dataItem.isValid ? AlternatorError.description(dataItem.value) : dataItem.invalidText
	}

	ListQuantity {
		//% "Field drive"
		text: qsTrId("alternator_wakespeed_field_drive")
		dataItem.uid: root.bindPrefix + "/FieldDrive"
		unit: VenusOS.Units_Percentage
		preferredVisible: dataItem.isValid
	}

	ListQuantity {
		//% "Utilization"
		text: qsTrId("alternator_wakespeed_utilization")
		dataItem.uid: root.bindPrefix + "/Utilization"
		unit: VenusOS.Units_Percentage
		preferredVisible: dataItem.isValid
	}

	ListQuantity {
		text: CommonWords.speed
		dataItem.uid: root.bindPrefix + "/Speed"
		unit: VenusOS.Units_RevolutionsPerMinute
		preferredVisible: dataItem.isValid
	}

	ListQuantity {
		//% "Engine speed"
		text: qsTrId("alternator_wakespeed_engine_speed")
		dataItem.uid: root.bindPrefix + "/Engine/Speed"
		unit: VenusOS.Units_RevolutionsPerMinute
		preferredVisible: dataItem.isValid
	}

	ListTemperature {
		//% "Engine Temperature"
		text: qsTrId("engine_temperature")
		dataItem.uid: root.bindPrefix + "/Engine/Temperature"
		preferredVisible: dataItem.isValid
	}

	ListNavigation {
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

		ObjectModel {
			id: overallHistoryModel

			ListText {
				//% "Operation time"
				text: qsTrId("alternator_wakespeed_operation_time")
				secondaryText: Utils.secondsToString(dataItem.value, true)
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/OperationTime"
				preferredVisible: dataItem.isValid
			}

			ListQuantity {
				//% "Charged Ah"
				text: qsTrId("alternator_wakespeed_charged_ah")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/ChargedAh"
				unit: VenusOS.Units_AmpHour
				precision: 0
				preferredVisible: dataItem.isValid
			}

			ListText {
				//% "Cycles started"
				text: qsTrId("alternator_wakespeed_cycles_started")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/CyclesStarted"
				preferredVisible: dataItem.isValid
			}

			ListText {
				//% "Cycles completed"
				text: qsTrId("alternator_wakespeed_cycles_completed")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/CyclesCompleted"
				preferredVisible: dataItem.isValid
			}

			ListText {
				//% "Number of power-ups"
				text: qsTrId("alternator_wakespeed_nr_of_power_ups")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/NrOfPowerups"
				preferredVisible: dataItem.isValid
			}

			ListText {
				//% "Number of deep discharges"
				text: qsTrId("alternator_wakespeed_nr_of_deep_discharges")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/NrOfDeepDischarges"
				preferredVisible: dataItem.isValid
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
		//% "Charge cycle history"
		text: qsTrId("alternator_wakespeed_charge_cycle_history")
		preferredVisible: historyCyclesAvailable.isValid
		onClicked: {
			Global.pageManager.pushPage(chargeHistoryComponent, { "title": text })
		}

		Component {
			id: chargeHistoryComponent

			Page {
				GradientListView {
					model: historyCyclesAvailable.isValid ? historyCyclesAvailable.value + 1 : 1
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

	ListNavigation {
		text: CommonWords.device_info_title
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}
}
