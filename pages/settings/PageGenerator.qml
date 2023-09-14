/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Utils

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
		switch (generatorState.value) {
		case 2:
			//% "Warm-up"
			return qsTrId("page_generator_warm_up")
		case 3:
			//% "Cool-down"
			return qsTrId("page_generator_cool_down")
		case 4:
			//% "Stopping"
			return qsTrId("page_generator_stopping")
		case 10:
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

	GradientListView {
		id: settingsListView

		model: startStopModel

		DataPoint {
			id: relayFunction
			source: "com.victronenergy.settings/Settings/Relay/Function"
		}
	}

	ObjectModel {
		id: startStopModel

		ListTextItem {
			id: state

			text: CommonWords.state
			secondaryText: activeCondition.valid ? getState() : '---'
			enabled: false
		}

		ListRadioButtonGroup {
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
			dataSource: root.startStopBindPrefix + "/Error"
		}

		ListTextItem {
			//% "Run time"
			text: qsTrId("settings_page_relay_generator_run_time")
			secondaryText: dataValid ? Utils.secondsToString(dataValue, false) : "0"
			dataSource: root.startStopBindPrefix + "/Runtime"
			visible: generatorState.value in [1, 2, 3] // Running, Warm-up, Cool-down
		}

		ListTextItem {
			//% "Total run time"
			text: qsTrId("settings_page_relay_generator_total_run_time")
			secondaryText: Utils.secondsToString(dataValue, false)
			dataSource: root.settingsBindPrefix + "/AccumulatedTotal"
		}

		ListTextItem {
			//% "Accumulated running time since last test run"
			text: qsTrId("settings_page_relay_generator_accumulated_running_time")
			showAccessLevel: VenusOS.User_AccessType_Service
			visible: defaultVisible && nextTestRun.visible
			secondaryText: Utils.secondsToString(dataValue, false)
			dataSource: root.startStopBindPrefix + "/TestRunIntervalRuntime"
		}

		ListTextItem {
			id: nextTestRun
			//% "Time to next test run"
			text: qsTrId("settings_page_relay_generator_time_to_next_test_run")
			secondaryText: ""
			dataSource: root.startStopBindPrefix + "/NextTestRun"
			visible: dataValid && dataValue > 0

			Timer {
				running: parent.visible && root.animationEnabled
				repeat: true
				interval: 1000
				onTriggered: {
					var now = new Date().getTime() / 1000
					var remainingTime = parent.dataValue - now
					if (remainingTime > 0) {
						parent.secondaryText = Utils.secondsToString(remainingTime, false)
						return
					}
					//% "Running now"
					parent.secondaryText = qsTrId("settings_page_relay_generator_running_now")
				}
			}
		}

		ListSwitch {
			//% "Auto start functionality"
			text: qsTrId("settings_page_relay_generator_auto_start_enabled")
			dataSource: root.settingsBindPrefix + "/AutoStartEnabled"
			visible: allowDisableAutostart
		}

		ListNavigationItem {
			//% "Manual start"
			text: qsTrId("settings_page_relay_generator_manual_start")
			onClicked: Global.pageManager.pushPage(manualStartPage, { title: text })

			Component {
				id: manualStartPage

				Page {
					GradientListView {

						model: ObjectModel {

							ListSwitch {
								id: manualSwitch
								//% "Start generator"
								text: qsTrId("settings_page_relay_generator_start_generator")
								dataSource: root.startStopBindPrefix + "/ManualStart"
								writeAccessLevel: VenusOS.User_AccessType_User
								onClicked: {
									Global.generators.manualRunningNotification(!checked, stopTimer.value)
								}
							}

							ListTimeSelector {
								//% "Run for (hh:mm)"
								text: qsTrId("settings_page_relay_generator_run_for_hh_mm")
								enabled: !manualSwitch.checked
								dataSource: root.startStopBindPrefix + "/ManualStartTimer"
								writeAccessLevel: VenusOS.User_AccessType_User
							}
						}
					}
				}
			}
		}

		ListNavigationItem {
			//% "Daily run time"
			text: qsTrId("settings_page_relay_generator_daily_run_time")
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

		ListNavigationItem {
			//% "Settings"
			text: qsTrId("settings_page_relay_generator_settings")
			onClicked: {
				Global.pageManager.pushPage(pageSettingsGenerator,
					{ title: text, settingsBindPrefix: root.settingsBindPrefix, startStopBindPrefix: root.startStopBindPrefix })
			}
		}
	}

	Component {
		id: pageSettingsGenerator

		PageSettingsGenerator { }
	}
}
