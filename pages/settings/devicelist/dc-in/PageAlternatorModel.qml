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
		allowed: defaultAllowed && dataItem.isValid
	}

	ListDcInputQuantityGroup {
		bindPrefix: root.bindPrefix
	}

	ListDcOutputQuantityGroup {
		bindPrefix: root.bindPrefix
	}

	ListTemperatureItem {
		text: CommonWords.temperature
		dataItem.uid: root.bindPrefix + "/Dc/0/Temperature"
		allowed: defaultAllowed && dataItem.isValid
		onHeightChanged: console.trace()
	}

	ListTextItem {
		text: CommonWords.state
		secondaryText: Global.system.systemStateToText(dataItem.value)
		allowed: defaultAllowed && dataItem.isValid
		dataItem.uid: root.bindPrefix + "/State"
	}

	ListTextItem {
		text: CommonWords.network_status
		secondaryText: Global.systemSettings.networkStatusToText(dataItem.value)
		dataItem.uid: root.bindPrefix + "/Link/NetworkStatus"
		allowed: defaultAllowed && dataItem.isValid
	}

	ListTextItem {
		text: CommonWords.error
		dataItem.uid: root.bindPrefix + "/ErrorCode"
		allowed: defaultAllowed && dataItem.isValid
		secondaryText: dataItem.isValid ? ChargerError.description(dataItem.value) : dataItem.invalidText
	}

	ListTextItem {
		text: CommonWords.error
		dataItem.uid: root.bindPrefix + "/Error/0/Id"
		allowed: defaultAllowed && dataItem.isValid
		secondaryText: dataItem.isValid ? AlternatorError.description(dataItem.value) : dataItem.invalidText
	}

	ListQuantityItem {
		//% "Field drive"
		text: qsTrId("alternator_wakespeed_field_drive")
		dataItem.uid: root.bindPrefix + "/FieldDrive"
		unit: VenusOS.Units_Percentage
		allowed: defaultAllowed && dataItem.isValid
	}

	ListQuantityItem {
		text: CommonWords.speed
		dataItem.uid: root.bindPrefix + "/Speed"
		unit: VenusOS.Units_RevolutionsPerMinute
		allowed: defaultAllowed && dataItem.isValid
	}

	ListQuantityItem {
		//% "Engine speed"
		text: qsTrId("alternator_wakespeed_engine_speed")
		dataItem.uid: root.bindPrefix + "/Engine/Speed"
		unit: VenusOS.Units_RevolutionsPerMinute
		allowed: defaultAllowed && dataItem.isValid
	}

	ListNavigationItem {
		text: CommonWords.overall_history
		allowed: overallHistoryMonitor.hasVisibleItem
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

			ListTextItem {
				//% "Operation time"
				text: qsTrId("alternator_wakespeed_operation_time")
				secondaryText: Utils.secondsToString(dataItem.value, true)
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/OperationTime"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListQuantityItem {
				//% "Charged Ah"
				text: qsTrId("alternator_wakespeed_charged_ah")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/ChargedAh"
				unit: VenusOS.Units_AmpHour
				precision: 0
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTextItem {
				//% "Cycles started"
				text: qsTrId("alternator_wakespeed_cycles_started")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/CyclesStarted"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTextItem {
				//% "Cycles completed"
				text: qsTrId("alternator_wakespeed_cycles_completed")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/CyclesCompleted"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTextItem {
				//% "Number of power-ups"
				text: qsTrId("alternator_wakespeed_nr_of_power_ups")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/NrOfPowerups"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListTextItem {
				//% "Number of deep discharges"
				text: qsTrId("alternator_wakespeed_nr_of_deep_discharges")
				dataItem.uid: root.bindPrefix + "/History/Cumulative/User/NrOfDeepDischarges"
				allowed: defaultAllowed && dataItem.isValid
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

	ListNavigationItem {
		//% "Charge cycle history"
		text: qsTrId("alternator_wakespeed_charge_cycle_history")
		allowed: historyCyclesAvailable.isValid
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

	ListNavigationItem {
		text: CommonWords.device_info_title
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
					{ "title": text, "bindPrefix": root.bindPrefix })
		}
	}
}
