/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string settingsBindPrefix
	property string startStopBindPrefix
	property string gensetBindPrefix: ""

	readonly property var _dates: historicalData.isValid ? Object.keys(JSON.parse(historicalData.value)).reverse() : 0

	VeQuickItem {
		id: state

		uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/State" : ""
	}

	VeQuickItem {
		id: historicalData
		uid: root.settingsBindPrefix + "/AccumulatedDaily"
	}

	VeQuickItem {
		id: accumulatedTotalItem

		uid: settingsBindPrefix + "/AccumulatedTotal"
	}

	VeQuickItem {
		id: gensetOperatingHours

		uid: gensetBindPrefix + "/Engine/OperatingHours"
	}

	GradientListView {
		id: settingsListView

		model: ObjectModel {

			ListTextItem {
				//% "Total run time"
				text: qsTrId("page_settings_run_time_and_service_total_run_time")
				allowed: gensetOperatingHours.isValid
				secondaryText: Math.round(accumulatedTotalItem.value / 60 / 60) + "h"
			}

			ListIntField {
				id: setTotalRunTime

				//% "Generator total run time (hours)"
				text: qsTrId("page_settings_run_time_and_service_generator_total_run_time")
				secondaryText: Math.round(accumulatedTotalItem.value / 60 / 60) - Math.round(dataItem.value / 60 / 60) + "h"
				dataItem.uid: settingsBindPrefix + "/AccumulatedTotalOffset"
				enabled: userHasWriteAccess && state.value === 0
				allowed: dataItem.isValid && gensetBindPrefix === ""
				maximumLength: 6
				saveInput: function() {
					dataItem.setValue(accumulatedTotalItem.value - parseInt(textField.text, 10) * 60 * 60)
				}
			}

			ListNavigationItem {
				//% "Daily run time"
				text: qsTrId("settings_page_run_time_and_service_daily_run_time")
				onClicked: Global.pageManager.pushPage(dailyRunTimePage, { title: text })

				Component {
					id: dailyRunTimePage

					Page {
						GradientListView {
							model: _dates
							delegate: ListTextItem {
								text: Qt.formatDate(new Date(parseInt(_dates[index]) * 1000), "dd-MM-yyyy") // TODO: locale-specific date format?
								secondaryText: Utils.secondsToString(JSON.parse(historicalData.value)[_dates[index]], false)
							}
						}
					}
				}
			}

			ListButton {
				//% "Reset daily run time counters"
				text: qsTrId("page_settings_run_time_and_service_reset_daily_run_time_counters")
				button.text: CommonWords.press_to_reset
				onClicked: {
					if (state.value === 0) {
						var now = new Date()
						var today = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()))
						var todayInSeconds = today.getTime() / 1000
						resetDaily.setValue('{"%1" : 0}'.arg(todayInSeconds.toString()))
						//% "The daily runtime counter has been reset"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_run_time_and_service_runtime_counter_reset"))
					} else if (state.value === 1) {
						//% "It is not possible to modify the counters while the generator is running"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_run_time_and_service_runtime_counter_cant_reset_while_running"))
					}
				}

				VeQuickItem {
					id: resetDaily

					uid: settingsBindPrefix + "/AccumulatedDaily"
				}
			}

			ListTextItem {
				id: nextTestRun
				//% "Time to next test run"
				text: qsTrId("settings_page_run_time_and_service_time_to_next_test_run")
				secondaryText: ""
				dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/NextTestRun" : ""
				allowed: dataItem.isValid && dataItem.value > 0

				Timer {
					running: parent.allowed && root.animationEnabled
					repeat: true
					interval: 1000
					onTriggered: {
						var now = new Date().getTime() / 1000
						var remainingTime = parent.dataItem.value - now
						if (remainingTime > 0) {
							parent.secondaryText = Utils.secondsToString(remainingTime, false)
							return
						}
						//% "Running now"
						parent.secondaryText = qsTrId("settings_page_run_time_and_service_running_now")
					}
				}
			}

			ListTextItem {
				//% "Accumulated running time since last test run"
				text: qsTrId("settings_page_run_time_and_service_accumulated_running_time")
				showAccessLevel: VenusOS.User_AccessType_Service
				allowed: defaultAllowed && nextTestRun.allowed
				secondaryText: Utils.secondsToString(dataItem.value, false)
				dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/TestRunIntervalRuntime" : ""
			}

			ListTextItem {
				//% "Time to service"
				text: qsTrId("settings_page_run_time_and_service_time_to_service")
				dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/ServiceCounter" : ""
				secondaryText: Math.round(dataItem.value / 60 / 60) + "h"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListIntField {
				id: serviceInterval

				//% "Generator service interval (hours)"
				text: qsTrId("page_settings_generator_service_interval")
				secondaryText: Math.round(dataItem.value / 60 / 60)
				dataItem.uid: settingsBindPrefix + "/ServiceInterval"
				saveInput: function() {
					var serviceInterval = parseInt(textField.text, 10) * 60 * 60
					dataItem.setValue(serviceInterval)
					if (serviceInterval > 0) {
						//% "Service time interval set to %1h. Use the 'Reset service timer' button to reset the service timer."
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_run_time_and_service_service_time_interval").arg(textField.text))
					}
					else {
						//% "Service timer disabled."
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_run_time_and_service_service_time_disabled"))
					}
				}
			}

			ListButton {
				//% "Reset service timer"
				text: qsTrId("page_settings_run_time_and_service_reset_service_timer")
				button.text: CommonWords.press_to_reset
				allowed: serviceReset.isValid
				onClicked: {
					serviceReset.setValue(1)
					//% "The service timer has been reset"
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_run_time_and_service_service_timer_has_been_reset"))
				}

				VeQuickItem {
					id: serviceReset
					uid: root.startStopBindPrefix ? startStopBindPrefix + "/ServiceCounterReset" : ""
				}
			}
		}
	}
}
