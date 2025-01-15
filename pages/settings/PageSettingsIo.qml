/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	VeQItemTableModel {
		id: analogModel
		uids: [ BackendConnection.serviceUidForType("adc") + "/Devices" ]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}

	VeQItemSortTableModel {
		id: digitalModel
		filterRegExp: "/[1-9]$"
		model: VeQItemTableModel {
			uids: [ Global.systemSettings.serviceUid + "/Settings/DigitalInput" ]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
	}

	GradientListView {
		model: AllowedItemModel {

			ListNavigation {
				//% "Analog inputs"
				text: qsTrId("settings_io_analog_inputs")
				allowed: defaultAllowed && analogModel.rowCount > 0
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
								dataItem.uid: model.uid + "/Function"

								VeQuickItem {
									id: switchLabel
									uid: model.uid + "/Label"
								}
							}
						}
					}
				}
			}

			ListNavigation {
				//% "Digital inputs"
				text: qsTrId("settings_io_digital_inputs")
				allowed: defaultAllowed && digitalModel.rowCount > 0
				onClicked: {
					Global.pageManager.pushPage(digitalInputsComponent, {"title": text})
				}

				Component {
					id: digitalInputsComponent

					Page {
						readonly property var delegateOptionModel: [
							VenusOS.DigitalInput_Type_Disabled,
							VenusOS.DigitalInput_Type_PulseMeter,
							VenusOS.DigitalInput_Type_DoorAlarm,
							VenusOS.DigitalInput_Type_BilgePump,
							VenusOS.DigitalInput_Type_BilgeAlarm,
							VenusOS.DigitalInput_Type_BurglarAlarm,
							VenusOS.DigitalInput_Type_SmokeAlarm,
							VenusOS.DigitalInput_Type_FireAlarm,
							VenusOS.DigitalInput_Type_CO2Alarm,
							VenusOS.DigitalInput_Type_Generator,
							VenusOS.DigitalInput_Type_TouchInputControl
						].map(function(v) { return { value: v, display: VenusOS.digitalInput_typeToText(v)} } )

						GradientListView {
							model: digitalModel

							delegate: ListRadioButtonGroup {
								//: %1 = number of the digital input
								//% "Digital input %1"
								text: qsTrId("settings_io_digital_input").arg(model.uid.split('/').pop())
								dataItem.uid: model.uid + "/Type"
								optionModel: delegateOptionModel
							}
						}
					}
				}
			}
		}
	}
}
