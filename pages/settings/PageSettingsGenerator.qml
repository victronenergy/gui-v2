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
				enabled: dataValid && (generatorIsSet || checked)
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
				//% "Alarm when generator is not in auto start mode"
				text: qsTrId("page_settings_generator_alarm_when_not_in_auto_start")
				dataSource: settingsBindPrefix + "/Alarms/AutoStartDisabled"
				onClicked: {
					if (!checked) {
						//% "An alarm will be triggered when auto start function is left disabled for more than 10 minutes."
						Global.notificationLayer.showToastNotification(VenusOS.Notification_Info,
								qsTrId("page_settings_generator_alarm_info"), 12000)
					}
				}
			}

			ListSwitch {
				id: quietHours

				text: CommonWords.quiet_hours
				dataSource: settingsBindPrefix + "/QuietHours/Enabled"
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListTimeSelector {
				//% "Quiet hours start time"
				text: qsTrId("page_settings_generator_quiet_hours_start_time")
				dataSource: settingsBindPrefix + "/QuietHours/StartTime"
				visible: defaultVisible && quietHours.checked
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListTimeSelector {
				//% "Quiet hours end time"
				text: qsTrId("page_settings_generator_quiet_hours_end_time")
				dataSource: settingsBindPrefix + "/QuietHours/EndTime"
				visible: defaultVisible && quietHours.checked
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListNavigationItem {
				//% "Run time and service"
				text: qsTrId("page_settings_generator_run_time_and_service")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageGeneratorRuntimeService.qml",
													   {
														   title: text,
														   settingsBindPrefix: root.settingsBindPrefix,
														   startStopBindPrefix: root.startStopBindPrefix
													   })
			}
		}
	}
}

