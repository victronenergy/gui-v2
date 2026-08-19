/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property VeQuickItem locations

	//% "Add Modbus port and unit ID"
	title: qsTrId("page_settings_fronius_add_modbus_location")

	GradientListView {
		model: DelegateComponentModel {

			DelegateComponent {
				id: portDC
				property string secondaryText: "1502"
				function runValidation(saveMode) {
					if (port) {
						return port.runValidation(saveMode)
					}
					const valueAsInt = parseInt(secondaryText)
					if (isNaN(valueAsInt) || valueAsInt < 0 || valueAsInt > 65535) {
						//% "'%1' is not a valid port number. Use a number between 0-65535."
						return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("port_input_not_valid").arg(secondaryText))
					}
					return Utils.validationResult(VenusOS.InputValidation_Result_OK)
				}
				ListPortField {
					id: port
					secondaryText: "1502"
					Component.onCompleted: portDC.secondaryText = secondaryText
					onSecondaryTextChanged: portDC.secondaryText = secondaryText
				}
			}

			DelegateComponent {
				id: unitDC
				property string secondaryText: "1"
				function runValidation(saveMode) {
					if (unit) {
						return unit.runValidation(saveMode)
					}
					const valueAsInt = parseInt(secondaryText)
					if (isNaN(valueAsInt) || valueAsInt <= 0 || valueAsInt > 247) {
						//% "%1 is not a valid unit number. Use a number between 1-247."
						return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("page_settings_fronius_unitid_invalid").arg(secondaryText))
					}
					return Utils.validationResult(VenusOS.InputValidation_Result_OK)
				}
				ListIntField {
					id: unit

					//% "Unit ID"
					text: qsTrId("page_settings_fronius_add_modbus_unitid")
					secondaryText: "1"
					Component.onCompleted: unitDC.secondaryText = secondaryText
					onSecondaryTextChanged: unitDC.secondaryText = secondaryText
					validateInput: function() {
						const valueAsInt = parseInt(secondaryText)
						if (isNaN(valueAsInt) || valueAsInt <= 0 || valueAsInt > 247) {
							//% "%1 is not a valid unit number. Use a number between 1-247."
							return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("page_settings_fronius_unitid_invalid").arg(secondaryText))
						}
						return Utils.validationResult(VenusOS.InputValidation_Result_OK, "", valueAsInt)
					}
				}
			}

			DelegateComponent {
				ListButton {
					//% "Add"
					secondaryText: qsTrId("page_settings_fronius_add_modbus_location_button")
					onClicked: {
						const fields = [portDC, unitDC]
						for (let i = 0; i < fields.length; ++i) {
							const resultStatus = fields[i].runValidation(VenusOS.InputValidation_ValidateAndSave)
							if (resultStatus !== VenusOS.InputValidation_Result_OK) {
								return
							}
						}

						let s = [portDC.secondaryText, unitDC.secondaryText].join(':');
						if (locations.value && locations.value.length) {
							s = locations.value + ',' + s;
						}

						locations.setValue(s);
						Global.pageManager.popPage()
					}
				}
			}
		}
	}
}
