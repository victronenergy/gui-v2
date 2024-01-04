/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property string settingsBindPrefix
	property string startStopBindPrefix

	VeQuickItem {
		id: state

		uid: startStopBindPrefix + "/State"
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
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_generator_runtime_counter_reset"))
					} else if (state.value === 1) {
						//% "It is not possible to modify the counters while the generator is running"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_generator_runtime_counter_cant_reset_while_running"))
					}
				}

				VeQuickItem {
					id: resetDaily

					uid: settingsBindPrefix + "/AccumulatedDaily"
				}
			}

			ListTextField {
				id: setTotalRunTime

				//% "Generator total run time (hours)"
				text: qsTrId("page_settings_generator_total_run_time")
				secondaryText: Math.round(accumulatedTotalItem.value / 60 / 60) - Math.round(dataItem.value / 60 / 60)
				textField.inputMethodHints: Qt.ImhDigitsOnly
				dataItem.uid: settingsBindPrefix + "/AccumulatedTotalOffset"
				enabled: userHasWriteAccess && state.value === 0
				visible: dataItem.isValid
				textField.maximumLength: 6
				onAccepted: function(hours) {
					dataItem.setValue(accumulatedTotalItem.value - hours * 60 * 60)
				}

				VeQuickItem {
					id: accumulatedTotalItem

					uid: settingsBindPrefix + "/AccumulatedTotal"
				}
			}

			ListTextField {
				id: serviceInterval

				//% "Generator service interval (hours)"
				text: qsTrId("page_settings_generator_service_interval")
				secondaryText: Math.round(dataItem.value / 60 / 60)
				textField.inputMethodHints: Qt.ImhDigitsOnly
				dataItem.uid: settingsBindPrefix + "/ServiceInterval"
				onAccepted: function(hours) {
					dataItem.setValue(hours * 60 * 60)
					//% "Service time interval set to %1h. Use the 'Reset service timer' button to reset the service timer."
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_generator_service_time_interval").arg(hours))
				}
			}

			ListButton {
				//% "Reset service timer"
				text: qsTrId("page_settings_generator_reset_service_timer")
				button.text: CommonWords.press_to_reset
				visible: serviceReset.isValid
				onClicked: {
					serviceReset.setValue(1)
					//% "The service timer has been reset."
					Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_generator_service_timer_has_been_reset"))
				}

				VeQuickItem {
					id: serviceReset

					uid: startStopBindPrefix + "/ServiceCounterReset"
				}
			}
		}
	}
}
