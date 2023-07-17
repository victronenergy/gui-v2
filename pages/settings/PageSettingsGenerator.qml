/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property string settingsBindPrefix
	property string startStopBindPrefix

	GradientListView {
		id: settingsListView

		model: ObjectModel {

			ListNavigationItem {
				//% "Conditions"
				text: qsTrId("page_settings_generator_conditions")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageGeneratorConditions.qml", { title: text, bindPrefix: root.settingsBindPrefix })
			}

			ListSpinBox {
				//% "Minimum run time"
				text: qsTrId("page_settings_generator_minimum_run_time")
				dataSource: settingsBindPrefix + "/MinimumRuntime"
				suffix: "m"
				decimals: 0
			}

			ListSwitch {
				property bool generatorIsSet: acIn1Source.value === 2 || acIn2Source.value === 2
				//% "Detect generator at AC input"
				text: qsTrId("page_settings_generator_detect_generator_at_ac_input")
				dataSource: settingsBindPrefix + "/Alarms/NoGeneratorAtAcIn"
				enabled: valid && (generatorIsSet || checked)
				onClicked: {
					if (!checked) {
						if (!generatorIsSet) {
							//% "None of the AC inputs is set to generator. Go to the system setup page and set the correct AC input to generator in order to enable this functionality."
							Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_generator_detect_generator_not_set"),
																	   Theme.animation.generator.detectGeneratorNotSet.toastNotification.autoClose.duration)
						} else {
							//% "An alarm will be triggered when no power from the generator is detected at the inverter AC input. Make sure that the correct AC input is set to generator on the system setup page."
							Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_generator_detect_generator_set"),
																	   Theme.animation.generator.detectGeneratorSet.toastNotification.autoClose.duration)
						}
					}
				}

				DataPoint {
					id: acIn1Source

					source: "com.victronenergy.settings/Settings/SystemSetup/AcInput1"
				}

				DataPoint {
					id: acIn2Source

					source: "com.victronenergy.settings/Settings/SystemSetup/AcInput2"
				}
			}

			ListSwitch {
				id: timeZones

				text: CommonWords.quiet_hours
				dataSource: settingsBindPrefix + "/QuietHours/Enabled"
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListTimeSelector {
				//% "Quiet hours start time"
				text: qsTrId("page_settings_generator_quiet_hours_start_time")
				dataSource: settingsBindPrefix + "/QuietHours/StartTime"
				visible: defaultVisible && timeZones.checked
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListTimeSelector {
				//% "Quiet hours end time"
				text: qsTrId("page_settings_generator_quiet_hours_end_time")
				dataSource: settingsBindPrefix + "/QuietHours/EndTime"
				visible: defaultVisible && timeZones.checked
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListButton {
				//% "Reset daily run time counters"
				text: qsTrId("page_settings_generator_reset_daily_run_time_counters")
				//% "Press to reset"
				button.text: qsTrId("page_settings_generator_press_to_reset")
				onClicked: {
					if (state.value === 0) {
						var now = new Date()
						var today = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate())) /* ignore the 'M306' warning for this line.
							QtCreator thinks that functions that start with an uppercase letter are constructor functions that should only be used with new.
							'Date.UTC(...)' is a static method, not a constructor, this is fine. */
						var todayInSeconds = today.getTime() / 1000
						resetDaily.setValue('{"%1" : 0}'.arg(todayInSeconds.toString()))
						//% "The daily runtime counter has been reset"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_generator_runtime_counter_reset"))
					} else if (state.value === 1) {
						//% "It is not possible to modify the counters while the generator is running"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_generator_runtime_counter_cant_reset_while_running"))
					}
				}
				DataPoint {
					id: resetDaily

					source: settingsBindPrefix + "/AccumulatedDaily"
				}
			}

			ListTimeSelector {
				id: setTotalRunTime

				//% "Generator total run time (hours)"
				text: qsTrId("page_settings_generator_total_run_time")
				dataSource: settingsBindPrefix + "/AccumulatedTotal"
				secondaryText: Math.round(value / 60 / 60)
				maximumHour: 999999
				enabled: userHasWriteAccess && state.value === 0
			}
		}
		DataPoint {
			id: state

			source: startStopBindPrefix + "/State"
		}
	}
}

