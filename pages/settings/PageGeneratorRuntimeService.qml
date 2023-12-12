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

	DataPoint {
		id: state

		source: startStopBindPrefix + "/State"
	}

	GradientListView {
		id: settingsListView

		model: ObjectModel {

			ListButton {
				//% "Reset daily run time counters"
				text: qsTrId("page_settings_generator_reset_daily_run_time_counters")
				button.text: CommonWords.press_to_reset
				onClicked: {
					if (state.value === 0) {
						var now = new Date()
						var today = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()))
						var todayInSeconds = today.getTime() / 1000
						resetDaily.setValue('{"%1" : 0}'.arg(todayInSeconds.toString()))
						//% "The daily runtime counter has been reset"
						Global.showToastNotification(Enums.Notification_Info, qsTrId("page_settings_generator_runtime_counter_reset"))
					} else if (state.value === 1) {
						//% "It is not possible to modify the counters while the generator is running"
						Global.showToastNotification(Enums.Notification_Info, qsTrId("page_settings_generator_runtime_counter_cant_reset_while_running"))
					}
				}

				DataPoint {
					id: resetDaily

					source: settingsBindPrefix + "/AccumulatedDaily"
				}
			}

			ListTextField {
				id: setTotalRunTime

				//% "Generator total run time (hours)"
				text: qsTrId("page_settings_generator_total_run_time")
				secondaryText: Math.round(accumulatedTotalItem.value / 60 / 60) - Math.round(dataValue / 60 / 60)
				textField.inputMethodHints: Qt.ImhDigitsOnly
				dataSource: settingsBindPrefix + "/AccumulatedTotalOffset"
				enabled: userHasWriteAccess && state.value === 0
				visible: dataValid
				textField.maximumLength: 6
				onAccepted: function(hours) {
					setDataValue(accumulatedTotalItem.value - hours * 60 * 60)
				}

				DataPoint {
					id: accumulatedTotalItem

					source: settingsBindPrefix + "/AccumulatedTotal"
				}
			}

			ListTextField {
				id: serviceInterval

				//% "Generator service interval (hours)"
				text: qsTrId("page_settings_generator_service_interval")
				secondaryText: Math.round(dataValue / 60 / 60)
				textField.inputMethodHints: Qt.ImhDigitsOnly
				dataSource: settingsBindPrefix + "/ServiceInterval"
				onAccepted: function(hours) {
					setDataValue(hours * 60 * 60)
					//% "Service time interval set to %1h. Use the 'Reset service timer' button to reset the service timer."
					Global.showToastNotification(Enums.Notification_Info, qsTrId("page_settings_generator_service_time_interval").arg(hours))
				}
			}

			ListButton {
				//% "Reset service timer"
				text: qsTrId("page_settings_generator_reset_service_timer")
				button.text: CommonWords.press_to_reset
				visible: serviceReset.valid
				onClicked: {
					serviceReset.setValue(1)
					//% "The service timer has been reset."
					Global.showToastNotification(Enums.Notification_Info, qsTrId("page_settings_generator_service_timer_has_been_reset"))
				}

				DataPoint {
					id: serviceReset

					source: startStopBindPrefix + "/ServiceCounterReset"
				}
			}
		}
	}
}
