/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string settingsBindPrefix: Global.systemSettings.serviceUid + "/Settings/Generator0"
	property string startStopBindPrefix: generator0ServiceUid

	// The generator start/stop service is always com.victronenergy.generator.startstop0 on D-Bus,
	// and mqtt/generator/0 on MQTT.
	readonly property string generator0ServiceUid: BackendConnection.type === BackendConnection.MqttSource
			? "mqtt/generator/0"
			: BackendConnection.uidPrefix() + "/com.victronenergy.generator.startstop0"

	readonly property alias generatorState: _generatorState
	property alias startStopModel: startStopModel
	property alias model: settingsListView.model

	readonly property var _dates: historicalData.isValid ? Object.keys(JSON.parse(historicalData.value)).reverse() : 0

	VeQuickItem {
		id: _generatorState
		uid: root.startStopBindPrefix + "/State"
	}

	VeQuickItem {
		id: historicalData
		uid: root.settingsBindPrefix + "/AccumulatedDaily"
	}

	GradientListView {
		id: settingsListView

		model: startStopModel

		VeQuickItem {
			id: relayFunction
			uid: Global.systemSettings.serviceUid + "/Settings/Relay/Function"
		}
	}

	ObjectModel {
		id: startStopModel

		ListTextItem {
			id: state

			text: CommonWords.state
			allowed: root.startStopBindPrefix === root.generator0ServiceUid
			secondaryText: activeCondition.isValid ? Global.generators.stateToText(generatorState.value, activeCondition.value) : '---'

			VeQuickItem {
				id: activeCondition
				uid: root.startStopBindPrefix + "/RunningByConditionCode"
			}
		}

		ListGeneratorError {
			allowed: root.startStopBindPrefix === root.generator0ServiceUid
			dataItem.uid: root.startStopBindPrefix + "/Error"
		}

		ListTextItem {
			//% "Run time"
			text: qsTrId("settings_page_relay_generator_run_time")
			secondaryText: dataItem.isValid ? Utils.secondsToString(dataItem.value, false) : "0"
			dataItem.uid: root.startStopBindPrefix + "/Runtime"
			allowed: generatorState.value in [1, 2, 3] // Running, Warm-up, Cool-down
		}

		ListTextItem {
			//% "Total run time"
			text: qsTrId("settings_page_relay_generator_total_run_time")
			secondaryText: Utils.secondsToString((accumulatedTotal.value || 0) - (accumulatedTotalOffset.value || 0), false)

			VeQuickItem {
				id: accumulatedTotal
				uid: root.settingsBindPrefix + "/AccumulatedTotal"
			}
			VeQuickItem {
				id: accumulatedTotalOffset
				uid: root.settingsBindPrefix + "/AccumulatedTotalOffset"
			}
		}

		ListTextItem {
			//% "Time to service"
			text: qsTrId("settings_page_relay_generator_time_to_service")
			dataItem.uid: root.startStopBindPrefix + "/ServiceCounter"
			secondaryText: Utils.secondsToString(dataItem.value, false)
			allowed: defaultAllowed && dataItem.isValid
		}

		ListTextItem {
			//% "Accumulated running time since last test run"
			text: qsTrId("settings_page_relay_generator_accumulated_running_time")
			showAccessLevel: VenusOS.User_AccessType_Service
			allowed: defaultAllowed && nextTestRun.allowed
			secondaryText: Utils.secondsToString(dataItem.value, false)
			dataItem.uid: root.startStopBindPrefix + "/TestRunIntervalRuntime"
		}

		ListTextItem {
			id: nextTestRun
			//% "Time to next test run"
			text: qsTrId("settings_page_relay_generator_time_to_next_test_run")
			secondaryText: ""
			dataItem.uid: root.startStopBindPrefix + "/NextTestRun"
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
					parent.secondaryText = qsTrId("settings_page_relay_generator_running_now")
				}
			}
		}

		ListSwitch {
			//% "Autostart functionality"
			text: qsTrId("settings_page_relay_generator_auto_start_enabled")
			dataItem.uid: root.startStopBindPrefix + "/AutoStartEnabled"
			allowed: root.startStopBindPrefix === root.generator0ServiceUid
		}

		ListNavigationItem {
			text: CommonWords.manual_start
			allowed: root.startStopBindPrefix === root.generator0ServiceUid
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageGeneratorManualStart.qml",
						{ title: text, startStopBindPrefix: root.startStopBindPrefix })
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
			text: CommonWords.settings
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsGenerator.qml",
					{ title: text, settingsBindPrefix: root.settingsBindPrefix, startStopBindPrefix: root.startStopBindPrefix })
			}
		}
	}
}
