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
	property int warmupCapability: 1

	VeQuickItem {
		id: capabilities

		uid: startStopBindPrefix + "/Capabilities"
	}

	VeQuickItem {
		id: noGeneratorAtDcInAlarm
		uid: startStopBindPrefix + "/Alarms/NoGeneratorAtDcIn"
	}

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {

			ListNavigation {
				//% "Conditions"
				text: qsTrId("page_settings_generator_conditions")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageGeneratorConditions.qml", { title: text, bindPrefix: root.settingsBindPrefix, startStopBindPrefix: root.startStopBindPrefix })
			}

			ListSpinBox {
				//% "Minimum run time"
				text: qsTrId("page_settings_generator_minimum_run_time")
				dataItem.uid: settingsBindPrefix + "/MinimumRuntime"
				suffix: "m"
				decimals: 0
			}

			ListNavigation {
				//% "Warm-up & cool-down"
				text: qsTrId("settings_page_generator_warm_up_cool_down")
				preferredVisible: capabilities.value & warmupCapability
				onClicked: Global.pageManager.pushPage(warmupPageComponent, { title: text })

				Component {
					id: warmupPageComponent
					Page {
						GradientListView {
							id: settingsListView

							model: VisibleItemModel {
								ListSpinBox {
									//% "Warm-up time"
									text: qsTrId("page_settings_generator_warm_up_time")
									dataItem.uid: settingsBindPrefix + "/WarmUpTime"
									suffix: "s"
									decimals: 0
									stepSize: 10
								}

								ListSpinBox {
									//% "Cool-down time"
									text: qsTrId("page_settings_generator_cool_down_time")
									dataItem.uid: settingsBindPrefix + "/CoolDownTime"
									suffix: "s"
									decimals: 0
									stepSize: 10
								}

								ListSpinBox {
									//% "Generator stop time"
									text: qsTrId("page_settings_generator_stop_time")
									dataItem.uid: settingsBindPrefix + "/GeneratorStopTime"
									suffix: "s"
									decimals: 0
									stepSize: 1
								}
							}
						}
					}
				}
			}

			ListSwitch {
				property bool generatorIsSet: acIn1Source.value === 2 || acIn2Source.value === 2
				//% "Detect generator at AC input"
				text: qsTrId("page_settings_generator_detect_generator_at_ac_input")
				dataItem.uid: settingsBindPrefix + "/Alarms/NoGeneratorAtAcIn"
				interactive: dataItem.valid && (generatorIsSet || checked)
				preferredVisible: !noGeneratorAtDcInAlarm.valid
				onClicked: {
					if (!checked) {
						if (!generatorIsSet) {
							//% "None of the AC inputs is set to generator. Go to the system setup page and set the correct AC input to generator in order to enable this functionality."
							Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_generator_detect_generator_not_set"),
																	   Theme.animation_generator_detectGeneratorNotSet_toastNotification_autoClose_duration)
						} else {
							//% "An alarm will be triggered when no power from the generator is detected at the inverter AC input. Make sure that the correct AC input is set to generator on the system setup page."
							Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_generator_detect_generator_set"),
																	   Theme.animation_generator_detectGeneratorSet_toastNotification_autoClose_duration)
						}
					}
				}

				VeQuickItem {
					id: acIn1Source

					uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/AcInput1"
				}

				VeQuickItem {
					id: acIn2Source

					uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/AcInput2"
				}
			}

			ListSwitch {
				//% "Alarm if DC generator is not providing power"
				text: qsTrId("page_settings_generator_detect_generator_at_dc")
				dataItem.uid: settingsBindPrefix + "/Alarms/NoGeneratorAtDcIn"
				preferredVisible: noGeneratorAtDcInAlarm.valid
				onClicked: {
					if (!checked) {
							//% "An alarm will be triggered when the DC genset does not reach at least 5A within the first 5 minutes after starting"
							Global.showToastNotification(VenusOS.Notification_Info, qsTrId("page_settings_generator_detect_at_dc_in_generator_set"),
																	   Theme.animation_generator_detectGeneratorSet_toastNotification_autoClose_duration)
					}
				}
			}

			ListSwitch {
				//% "Alarm when generator is not in autostart mode"
				text: qsTrId("page_settings_generator_alarm_when_not_in_auto_start")
				dataItem.uid: settingsBindPrefix + "/Alarms/AutoStartDisabled"
				onClicked: {
					if (!checked) {
						//% "An alarm will be triggered when autostart function is left disabled for more than 10 minutes"
						Global.notificationLayer.showToastNotification(VenusOS.Notification_Info,
								qsTrId("page_settings_generator_alarm_info"), 12000)
					}
				}
			}

			ListSwitch {
				id: quietHours

				text: CommonWords.quiet_hours
				dataItem.uid: settingsBindPrefix + "/QuietHours/Enabled"
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListTimeSelector {
				//% "Quiet hours start time"
				text: qsTrId("page_settings_generator_quiet_hours_start_time")
				dataItem.uid: settingsBindPrefix + "/QuietHours/StartTime"
				preferredVisible: quietHours.checked
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListTimeSelector {
				//% "Quiet hours end time"
				text: qsTrId("page_settings_generator_quiet_hours_end_time")
				dataItem.uid: settingsBindPrefix + "/QuietHours/EndTime"
				preferredVisible: quietHours.checked
				writeAccessLevel: VenusOS.User_AccessType_User
			}
		}
	}
}

