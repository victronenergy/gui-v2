/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: VisibleItemModel {

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
					//% "Genset start/stop"
					{ display: qsTrId("settings_relay_genset_start_stop"), value: VenusOS.Relay_Function_GeneratorStartStop },
					//% "Connected genset helper relay"
					{ display: qsTrId("settings_relay_genset_helper_relay"), value: VenusOS.Relay_Function_GensetHelperRelay },
					//% "Tank pump"
					{ display: qsTrId("settings_relay_tank_pump"), value: VenusOS.Relay_Function_Tank_Pump },
					//% "Manual"
					{ display: qsTrId("settings_relay_manual"), value: VenusOS.Relay_Function_Manual },
					{ display: CommonWords.temperature, value: VenusOS.Relay_Function_Temperature },
				]
				onOptionClicked: function(index) {
					switch (optionModel[index].value) {
					case VenusOS.Relay_Function_GeneratorStartStop:
						//% "The Genset can now be found in the devices list"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_relay_genset_can_now_be_found"), 5000)
						break
					case VenusOS.Relay_Function_Tank_Pump:
						//% "The Tank Pump can now be found in the devices list"
						Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_relay_tank_pump_can_now_be_found"), 5000)
						break
					default:
						break
					}
				}
			}

			ListRadioButtonGroup {
				id: alarmPolaritySwitch

				//% "Alarm relay polarity"
				text: qsTrId("settings_relay_alarm_polarity")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Relay/Polarity"
				preferredVisible: relayFunction.currentValue === VenusOS.Relay_Function_Alarm
				optionModel: [
					//% "Normally open"
					{ display: qsTrId("settings_relay_normally_open"), value: 0 },
					//% "Normally closed"
					{ display: qsTrId("settings_relay_normally_closed"), value: 1 },
				]
			}

			ListSwitch {
				id: manualSwitch

				text: relay1State.isValid
					  //% "Relay 1 on"
					? qsTrId("settings_relay_relay1on")
					  //% "Relay on"
					: qsTrId("settings_relay_on")
				dataItem.uid: Global.system.serviceUid + "/Relay/0/State"
				preferredVisible: relayFunction.currentValue === VenusOS.Relay_Function_Manual
			}

			ListRadioButtonGroup {
				id: relay1Function

				//% "Function (Relay 2)"
				text: qsTrId("settings_relay_function_relay2")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Relay/1/Function"
				preferredVisible: relay1State.isValid
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
				preferredVisible: relay1State.isValid
					&& relay1Function.currentValue === VenusOS.Relay_Function_Manual
			}

			ListNavigation {
				//% "Temperature control rules"
				text: qsTrId("settings_relay_temp_control_rules")
				preferredVisible: relayFunction.currentValue === VenusOS.Relay_Function_Temperature
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
