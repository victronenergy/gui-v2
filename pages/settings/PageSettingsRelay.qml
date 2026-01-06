/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	function notifyRelayFunctionChange(relayFunction) {
		switch (relayFunction) {
		case VenusOS.SwitchableOutput_Function_GeneratorStartStop:
			//% "The Genset can now be found in the devices list"
			Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_relay_genset_can_now_be_found"), 5000)
			break
		case VenusOS.SwitchableOutput_Function_Tank_Pump:
			//% "The Tank Pump can now be found in the devices list"
			Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_relay_tank_pump_can_now_be_found"), 5000)
			break
		case VenusOS.SwitchableOutput_Function_Manual:
			//% "The Relay can now be found in the devices list"
			Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_relay_manual_can_now_be_found"), 5000)
			break
		default:
			break
		}
	}

	SwitchableOutputModel {
		id: systemRelayModel
		sourceModel: VeQItemTableModel {
			uids: [ Global.system.serviceUid + "/SwitchableOutput" ]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		filterType: SwitchableOutputModel.ManualFunction
	}

	GradientListView {
		model: VisibleItemModel {

			ListRadioButtonGroup {
				id: relayFunction

				text: relay1State.seen
					  //% "Function (Relay 1)"
					? qsTrId("settings_relay_function_relay1")
					  //% "Function"
					: qsTrId("settings_relay_function")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Relay/Function"
				optionModel: [
					//% "Disabled"
					{ display: qsTrId("settings_relay_disabled"), value: VenusOS.SwitchableOutput_Function_Disabled },
					//% "Alarm relay"
					{ display: qsTrId("settings_relay_alarm_relay"), value: VenusOS.SwitchableOutput_Function_Alarm },
					//% "Genset start/stop"
					{ display: qsTrId("settings_relay_genset_start_stop"), value: VenusOS.SwitchableOutput_Function_GeneratorStartStop },
					//% "Connected genset helper relay"
					{ display: qsTrId("settings_relay_genset_helper_relay"), value: VenusOS.SwitchableOutput_Function_GensetHelperRelay },
					//% "Tank pump"
					{ display: qsTrId("settings_relay_tank_pump"), value: VenusOS.SwitchableOutput_Function_Tank_Pump },
					//% "Manual"
					{ display: qsTrId("settings_relay_manual"), value: VenusOS.SwitchableOutput_Function_Manual },
					{ display: CommonWords.temperature, value: VenusOS.SwitchableOutput_Function_Temperature },
				]
				onOptionClicked: function(index) {
					root.notifyRelayFunctionChange(optionModel[index].value)
				}
			}

			ListRadioButtonGroup {
				id: relayPolaritySwitch
				text: relay1State.seen
					  //% "Polarity (Relay 1)"
					? qsTrId("settings_relay_polarity_relay1")
					  //% "Polarity"
					: qsTrId("settings_relay_polarity")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Relay/Polarity"
				preferredVisible: [VenusOS.SwitchableOutput_Function_Alarm, VenusOS.SwitchableOutput_Function_Manual].indexOf(relayFunction.currentValue) >= 0
				optionModel: [
					//% "Normally open"
					{ display: qsTrId("settings_relay_normally_open"), value: 0 },
					//% "Normally closed"
					{ display: qsTrId("settings_relay_normally_closed"), value: 1 },
				]
			}

			ListRadioButtonGroup {
				id: relay1Function

				//% "Function (Relay 2)"
				text: qsTrId("settings_relay_function_relay2")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Relay/1/Function"
				preferredVisible: relay1State.seen
				optionModel: [
					//% "Disabled"
					{ display: qsTrId("settings_relay_disabled"), value: VenusOS.SwitchableOutput_Function_Disabled },
					//% "Manual"
					{ display: qsTrId("settings_relay_manual"), value: VenusOS.SwitchableOutput_Function_Manual },
					{ display: CommonWords.temperature, value: VenusOS.SwitchableOutput_Function_Temperature },
				]
				onOptionClicked: function(index) {
					root.notifyRelayFunctionChange(optionModel[index].value)
				}
			}

			ListRadioButtonGroup {
				id: relay1PolaritySwitch
				//% "Polarity (Relay 2)"
				text: qsTrId("settings_relay_polarity_relay2")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Relay/1/Polarity"
				preferredVisible: relay1Function.currentValue === VenusOS.SwitchableOutput_Function_Manual
				optionModel: relayPolaritySwitch.optionModel
			}

			ListNavigation {
				//% "Temperature control rules"
				text: qsTrId("settings_relay_temp_control_rules")
				preferredVisible: relayFunction.currentValue === VenusOS.SwitchableOutput_Function_Temperature
					|| relay1Function.currentValue === VenusOS.SwitchableOutput_Function_Temperature
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
