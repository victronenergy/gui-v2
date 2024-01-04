/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	readonly property var _relay0Object: Global.relays.model.count > 0 ? Global.relays.model.deviceAt(0) : null

	GradientListView {
		model: ObjectModel {

			ListRadioButtonGroup {
				id: relayFunction

				text: relay1State.isValid
					  //% "Function (Relay 1)"
					? qsTrId("settings_relay_function_relay1")
					  //% "Function"
					: qsTrId("settings_relay_function")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Relay/Function"
				optionModel: [
					//% "Alarm relay"
					{ display: qsTrId("settings_relay_alarm_relay"), value: VenusOS.Relay_Function_Alarm },
					//% "Generator start/stop"
					{ display: qsTrId("settings_relay_generator_start_stop"), value: VenusOS.Relay_Function_GeneratorStartStop },
					//% "Tank pump"
					{ display: qsTrId("settings_relay_tank_pump"), value: VenusOS.Relay_Function_Tank_Pump },
					//% "Manual"
					{ display: qsTrId("settings_relay_manual"), value: VenusOS.Relay_Function_Manual },
					{ display: CommonWords.temperature, value: VenusOS.Relay_Function_Temperature },
				]
			}

			ListRadioButtonGroup {
				id: alarmPolaritySwitch

				//% "Alarm relay polarity"
				text: qsTrId("settings_relay_alarm_polarity")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Relay/Polarity"
				visible: relayFunction.currentValue === VenusOS.Relay_Function_Alarm
				optionModel: [
					//% "Normally open"
					{ display: qsTrId("settings_relay_normally_open"), value: 0 },
					//% "Normally closed"
					{ display: qsTrId("settings_relay_normally_closed"), value: 1 },
				]
			}

			ListSwitch {
				id: relaySwitch

				//% "Alarm relay on"
				text: qsTrId("settings_relay_alarm_relay_on")
				updateOnClick: false
				checked: root._relay0Object && _relay0Object.state === VenusOS.Relays_State_Active

				visible: relayFunction.currentValue === VenusOS.Relay_Function_Alarm
				onClicked: {
					// TODO in gui-v1 the relay state change considers relay polarity and alarm status.
					// In gui-v2 we will connect to venus-platform or some backend to do this.
					const newState = checked ? VenusOS.Relays_State_Inactive : VenusOS.Relays_State_Active
					root._relay0Object.setState(newState)
				}
			}

			ListSwitch {
				id: manualSwitch

				text: relay1State.isValid
					  //% "Relay 1 on"
					? qsTrId("settings_relay_relay1on")
					  //% "Relay on"
					: qsTrId("settings_relay_on")
				dataItem.uid: Global.system.serviceUid + "/Relay/0/State"
				visible: relayFunction.currentValue === VenusOS.Relay_Function_Manual
			}

			ListRadioButtonGroup {
				id: relay1Function

				//% "Function (Relay 2)"
				text: qsTrId("settings_relay_function_relay2")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Relay/1/Function"
				visible: relay1State.isValid
				optionModel: [
					//% "Manual"
					{ display: qsTrId("settings_relay_manual"), value: VenusOS.Relay_Function_Manual },
					{ display: CommonWords.temperature, value: VenusOS.Relay_Function_Temperature },
				]
			}

			ListSwitch {
				id: manualSwitch1

				//% "Relay 2 on"
				text: qsTrId("settings_relay_relay2on")
				dataItem.uid: Global.system.serviceUid + "/Relay/1/State"
				visible: relay1State.isValid && relay1Function.currentValue === VenusOS.Relay_Function_Manual
			}

			ListNavigationItem {
				//% "Temperature control rules"
				text: qsTrId("settings_relay_temp_control_rules")
				visible: relayFunction.currentValue === VenusOS.Relay_Function_Temperature
					|| relay1Function.currentValue === VenusOS.Relay_Function_Temperature
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsRelayTempSensors.qml", { title: text })
				}
			}
		}
	}

	VeQuickItem {
		id: relay1State
		uid: Global.system.serviceUid + "/Relay/1/State"
	}
}
