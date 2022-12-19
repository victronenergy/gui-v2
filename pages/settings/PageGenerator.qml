/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property bool allowDisableAutostart: true
	readonly property string settingsBindPrefix: "com.victronenergy.settings/Settings/Generator0"
	readonly property string startStopBindPrefix: "com.victronenergy.generator.startstop0"
	readonly property alias generatorState: _generatorState
	readonly property alias activeCondition: _activeCondition
	property alias startStopModel: startStopModel
	property alias model: settingsListView.model
	readonly property variant _dates: historicalData.valid ? Object.keys(JSON.parse(historicalData.value)).reverse() : 0

	function getState()
	{
		if (generatorState.value === 10) {
			return CommonWords.error
		}

		switch(activeCondition.value) {
		case 'soc':
			//% "Running by SOC condition"
			return qsTrId("settings_running_by_soc_condition")
		case 'acload':
			//% "Running by AC Load condition"
			return qsTrId("settings_running_by_ac_load_condition")
		case 'batterycurrent':
			//% "Running by battery current condition"
			return qsTrId("settings_running_by_battery_current_condition")
		case 'batteryvoltage':
			//% "Running by battery voltage condition"
			return qsTrId("settings_running_by_battery_voltage_condition")
		case 'inverterhightemp':
			//% "Running by inverter high temperature"
			return qsTrId("settings_running_by_inverter_high_temperature")
		case 'inverteroverload':
			//% "Running by inverter overload"
			return qsTrId("settings_running_by_inverter_overload")
		case 'testrun':
			//% "Test run"
			return qsTrId("settings_running_by_test_run")
		case 'lossofcommunication':
			//% "Running by loss of communication"
			return qsTrId("settings_running_by_loss_of_communication")
		case 'manual':
			//% "Manually started"
			return qsTrId("settings_manually_started")
		default:
			return CommonWords.stopped
		}
	}

	DataPoint {
		id: _generatorState
		source: root.startStopBindPrefix + "/State"
	}

	DataPoint {
		id: _activeCondition
		source: root.startStopBindPrefix + "/RunningByCondition"
	}

	DataPoint {
		id: stopTimer
		source: startStopBindPrefix + "/ManualStartTimer"
	}

	DataPoint {
		id: historicalData
		source: root.settingsBindPrefix + "/AccumulatedDaily"
	}

	SettingsListView {
		id: settingsListView

		model: startStopModel

		DataPoint {
			id: relayFunction
			source: "com.victronenergy.settings/Settings/Relay/Function"
		}
	}

	ObjectModel {
		id: startStopModel

		SettingsListTextItem {
			id: state

			text: CommonWords.state
			secondaryText: activeCondition.valid ? getState() : '---'
			enabled: false
		}

		SettingsListRadioButtonGroup {
			text: CommonWords.error
			optionModel: [
				{ display: CommonWords.no_error, value: 0 },
				//% "Remote switch control disabled"
				{ display: qsTrId("settings_remote_switch_control_disabled"), value: 1 },
				//% "Generator in fault condition"
				{ display: qsTrId("settings_generator_in_fault_condition"), value: 2 },
				//% "Generator not detected at AC input"
				{ display: qsTrId("settings_generator_not_detected"), value: 3 },
			]
			enabled: false
			source: root.startStopBindPrefix + "/Error"
		}

		SettingsListTextItem {
			//% "Run time"
			text: qsTrId("settings_page_relay_generator_run_time")
			secondaryText: dataPoint.valid ? Utils.secondsToString(dataPoint.value, false) : "0"
			source: root.startStopBindPrefix + "/Runtime"
			visible: generatorState.value === 1
		}

		SettingsListTextItem {
			//% "Total run time"
			text: qsTrId("settings_page_relay_generator_total_run_time")
			secondaryText: Utils.secondsToString(dataPoint.value, false)
			source: root.settingsBindPrefix + "/AccumulatedTotal"
		}

		SettingsListTextItem {
			//% "Accumulated running time since last test run"
			text: qsTrId("settings_page_relay_generator_accumulated_running_time")
			showAccessLevel: VenusOS.User_AccessType_Service
			visible: defaultVisible && nextTestRun.visible
			secondaryText: Utils.secondsToString(dataPoint.value, false)
			source: root.startStopBindPrefix + "/TestRunIntervalRuntime"
		}

		SettingsListTextItem {
			id: nextTestRun
			//% "Time to next test run"
			text: qsTrId("settings_page_relay_generator_time_to_next_test_run")
			secondaryText: ""
			source: root.startStopBindPrefix + "/NextTestRun"
			visible: dataPoint.valid && dataPoint.value > 0

			Timer {
				running: parent.visible
				repeat: true
				interval: 1000
				onTriggered: {
					var now = new Date().getTime() / 1000
					var remainingTime = parent.dataPoint.value - now
					if (remainingTime > 0) {
						parent.secondaryText = Utils.secondsToString(remainingTime, false)
						return
					}
					//% "Running now"
					parent.secondaryText = qsTrId("settings_page_relay_generator_running_now")
				}
			}
		}

		SettingsListSwitch {
			//% "Auto start functionality"
			text: qsTrId("settings_page_relay_generator_auto_start_enabled")
			source: root.settingsBindPrefix + "/AutoStartEnabled"
			visible: allowDisableAutostart
		}

		SettingsListNavigationItem {
			//% "Manual start"
			text: qsTrId("settings_page_relay_generator_manual_start")
			onClicked: Global.pageManager.pushPage(manualStartPage, { title: text })

			Component {
				id: manualStartPage

				Page {
					SettingsListView {

						model: ObjectModel {

							SettingsListSwitch {
								id: manualSwitch
								//% "Start generator"
								text: qsTrId("settings_page_relay_generator_start_generator")
								source: root.startStopBindPrefix + "/ManualStart"
								writeAccessLevel: VenusOS.User_AccessType_User
								onClicked: {
									if (checked) {
										//% "Stopping, generator will continue running if other conditions are reached"
										Global.dialogManager.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_page_relay_generator_stopping"),
																				   Theme.animation.generator.stopping.toastNotification.autoClose.duration)
									}
									if (!checked && stopTimer.value === 0) {
										//% "Starting, generator won't stop till user intervention"
										Global.dialogManager.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_page_relay_generator_starting_wont_stop"),
																				   Theme.animation.generator.starting.toastNotification.autoClose.duration)
									}
									if (!checked && stopTimer.value > 0) {
										//% "Starting. The generator will stop in %1, unless other conditions keep it running"
										Global.dialogManager.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_page_relay_generator_starting_will_stop").arg(Utils.secondsToString(stopTimer.value)),
																				   Theme.animation.generator.starting.toastNotification.autoClose.duration)
									}
								}
							}

							SettingsListTimeSelector {
								//% "Run for (hh:mm)"
								text: qsTrId("settings_page_relay_generator_run_for_hh_mm")
								enabled: !manualSwitch.checked
								source: root.startStopBindPrefix + "/ManualStartTimer"
								writeAccessLevel: VenusOS.User_AccessType_User
							}
						}
					}
				}
			}
		}

		SettingsListNavigationItem {
			//% "Daily run time"
			text: qsTrId("settings_page_relay_generator_daily_run_time")
			onClicked: Global.pageManager.pushPage(dailyRunTimePage, { title: text })

			Component {
				id: dailyRunTimePage

				Page {
					SettingsListView {
						model: _dates
						delegate: SettingsListTextItem {
							text: Qt.formatDate(new Date(parseInt(_dates[index]) * 1000), "dd-MM-yyyy") // TODO: locale-specific date format?
							secondaryText: Utils.secondsToString(JSON.parse(historicalData.value)[_dates[index]], false)
						}
					}
				}
			}
		}

		SettingsListNavigationItem {
			//% "Settings"
			text: qsTrId("settings_page_relay_generator_settings")
			onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsGenerator.qml", { title: text, settingsBindPrefix: root.settingsBindPrefix, startStopBindPrefix: root.startStopBindPrefix })
		}
	}
}
