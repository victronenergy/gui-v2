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

	readonly property var _dates: historicalData.valid ? Object.keys(JSON.parse(historicalData.value)).reverse() : 0

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

	VisibleItemModel {
		id: startStopModel

		ListSwitch {
			//% "Autostart functionality"
			text: qsTrId("settings_page_relay_generator_auto_start_enabled")
			dataItem.uid: root.startStopBindPrefix + "/AutoStartEnabled"
			preferredVisible: root.startStopBindPrefix === root.generator0ServiceUid
		}

		ListItem {
			text: CommonWords.manual_control
			preferredVisible: root.startStopBindPrefix === root.generator0ServiceUid
			content.children: [
				GeneratorManualControlButton {
					generatorUid: root.startStopBindPrefix
					gensetUid: ""
				}
			]
		}

		ListText {
			//% "Current run time"
			text: qsTrId("settings_page_relay_generator_run_time")
			secondaryText: dataItem.valid ? Utils.secondsToString(dataItem.value, false) : "0"
			dataItem.uid: root.startStopBindPrefix + "/Runtime"
			preferredVisible: generatorState.value >= 1 && generatorState.value <= 3 // Running, Warm-up, Cool-down
		}

		ListText {
			id: state

			text: CommonWords.state
			preferredVisible: root.startStopBindPrefix === root.generator0ServiceUid
			secondaryText: activeCondition.isAutoStarted && generatorState.value === VenusOS.Generators_State_Running
						   ? CommonWords.autostarted_dot_running_by.arg(Global.generators.runningByText(activeCondition.value))
						   : Global.generators.stateAndCondition(generatorState.value, activeCondition.value)

			VeQuickItem {
				id: activeCondition

				readonly property bool isAutoStarted: valid && Global.generators.isAutoStarted(value)

				uid: root.startStopBindPrefix + "/RunningByConditionCode"
			}
		}

		ListGeneratorError {
			preferredVisible: root.startStopBindPrefix === root.generator0ServiceUid
			dataItem.uid: root.startStopBindPrefix + "/Error"
		}

		ListNavigation {
			text: CommonWords.settings
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsGenerator.qml",
					{ title: text, settingsBindPrefix: root.settingsBindPrefix, startStopBindPrefix: root.startStopBindPrefix })
			}
		}

		ListNavigation {
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
