/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import net.connman 0.1
import "/components/Utils.js" as Utils

Page {
	id: root

	// TODO fix this model for MQTT
	VeQItemTableModel {
		id: analogModel
		uids: ["dbus/com.victronenergy.adc/Devices"]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}

	// TODO fix this model for MQTT
	VeQItemTableModel {
		id: digitalModel
		uids: ["dbus/com.victronenergy.settings/Settings/DigitalInput"]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}

	SettingsListView {
		model: ObjectModel {

			SettingsListNavigationItem {
				//% "Analog inputs"
				text: qsTrId("settings_io_analog_inputs")
				visible: defaultVisible && analogModel.rowCount > 0
				onClicked: {
					Global.pageManager.pushPage(analogInputsComponent, {"title": text})
				}

				Component {
					id: analogInputsComponent

					Page {
						SettingsListView {
							model: analogModel
							delegate: SettingsListSwitch {
								text: switchLabel.value || ""
								source: Utils.normalizedSource(model.uid) + "/Function"

								DataPoint {
									id: switchLabel
									source: Utils.normalizedSource(model.uid) + "/Label"
								}
							}
						}
					}
				}
			}

			SettingsListNavigationItem {
				//% "Digital inputs"
				text: qsTrId("settings_io_digital_inputs")
				visible: defaultVisible && digitalModel.rowCount > 0
				onClicked: {
					Global.pageManager.pushPage(digitalInputsComponent, {"title": text})
				}

				Component {
					id: digitalInputsComponent

					Page {
						SettingsListView {
							model: digitalModel

							delegate: SettingsListRadioButtonGroup {
								//: %1 = number of the digital input
								//% "Digital input %1"
								text: qsTrId("settings_io_digital_input").arg(model.uid.split('/').pop())
								source: Utils.normalizedSource(model.uid) + "/Type"
								optionModel: [
									{ display: CommonWords.disabled, value: VenusOS.DigitalInput_Disabled },
									//% "Pulse meter"
									{ display: qsTrId("settings_io_digital_input_pulse_meter"), value: VenusOS.DigitalInput_PulseMeter },
									//% "Door alarm"
									{ display: qsTrId("settings_io_digital_input_door_alarm"), value: VenusOS.DigitalInput_DoorAlarm },
									//% "Bilge pump"
									{ display: qsTrId("settings_io_digital_input_bilge_pump"), value: VenusOS.DigitalInput_BilgePump },
									//% "Bilge alarm"
									{ display: qsTrId("settings_io_digital_input_bilge_alarm"), value: VenusOS.DigitalInput_BilgeAlarm },
									//% "Burglar alarm"
									{ display: qsTrId("settings_io_digital_input_burglar_alarm"), value: VenusOS.DigitalInput_BurglarAlarm },
									//% "Smoke alarm"
									{ display: qsTrId("settings_io_digital_input_smoke_alarm"), value: VenusOS.DigitalInput_SmokeAlarm },
									//% "Fire alarm"
									{ display: qsTrId("settings_io_digital_input_bilge_fire"), value: VenusOS.DigitalInput_FireAlarm },
									//% "CO2 alarm"
									{ display: qsTrId("settings_io_digital_input_co2_alarm"), value: VenusOS.DigitalInput_CO2Alarm },
									//% "Generator"
									{ display: qsTrId("settings_io_digital_input_generator"), value: VenusOS.DigitalInput_Generator },
								]
							}
						}
					}
				}
			}

			SettingsListNavigationItem {
				//% "Bluetooth sensors"
				text: qsTrId("settings_io_bt_sensors")
				visible: Connman.technologyList.indexOf("bluetooth") !== -1
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsBleSensors.qml", {"title": text})
				}
			}
		}
	}
}
