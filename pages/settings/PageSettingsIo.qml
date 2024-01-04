/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import net.connman
import Victron.Utils

Page {
	id: root

	VeQItemTableModel {
		id: analogModel
		uids: [ BackendConnection.serviceUidForType("adc") + "/Devices" ]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}

	VeQItemTableModel {
		id: digitalModel
		uids: [ Global.systemSettings.serviceUid + "/Settings/DigitalInput" ]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}

	GradientListView {
		model: ObjectModel {

			ListNavigationItem {
				//% "Analog inputs"
				text: qsTrId("settings_io_analog_inputs")
				visible: defaultVisible && analogModel.rowCount > 0
				onClicked: {
					Global.pageManager.pushPage(analogInputsComponent, {"title": text})
				}

				Component {
					id: analogInputsComponent

					Page {
						GradientListView {
							model: analogModel
							delegate: ListSwitch {
								text: switchLabel.value || ""
								dataItem.uid: Utils.normalizedSource(model.uid) + "/Function"

								VeQuickItem {
									id: switchLabel
									uid: Utils.normalizedSource(model.uid) + "/Label"
								}
							}
						}
					}
				}
			}

			ListNavigationItem {
				//% "Digital inputs"
				text: qsTrId("settings_io_digital_inputs")
				visible: defaultVisible && digitalModel.rowCount > 0
				onClicked: {
					Global.pageManager.pushPage(digitalInputsComponent, {"title": text})
				}

				Component {
					id: digitalInputsComponent

					Page {
						GradientListView {
							model: digitalModel

							delegate: ListRadioButtonGroup {
								//: %1 = number of the digital input
								//% "Digital input %1"
								text: qsTrId("settings_io_digital_input").arg(model.uid.split('/').pop())
								dataItem.uid: Utils.normalizedSource(model.uid) + "/Type"
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
									{ display: CommonWords.generator, value: VenusOS.DigitalInput_Generator },
								]
							}
						}
					}
				}
			}

			ListNavigationItem {
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
