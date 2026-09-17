/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property VeQuickItem locations

	// Reports a validation result in the same way that TextValidationField.runValidation() does,
	// and returns the result status code (not the result object). Used by the fallback validation
	// in the delegate components below, when their text field delegate is not instantiated.
	function _reportValidation(result, saveMode) {
		if (saveMode === VenusOS.InputValidation_ValidateAndSave && result.notificationText.length > 0) {
			Global.showToastNotification(result.status === VenusOS.InputValidation_Result_Error
					? VenusOS.Notification_Alarm
					: VenusOS.Notification_Info,
					result.notificationText, 5000)
		}
		return result.status
	}

	//% "Add Modbus port and unit ID"
	title: qsTrId("page_settings_fronius_add_modbus_location")

	GradientListView {
		model: DelegateComponentModel {

			DelegateComponent {
				id: portDC
				property string secondaryText: "1502"
				property ListTextField field
				function runValidation(saveMode) {
					if (field) {
						return field.runValidation(saveMode)
					}
					const valueAsInt = parseInt(secondaryText)
					if (isNaN(valueAsInt) || valueAsInt < 0 || valueAsInt > 65535) {
						//% "'%1' is not a valid port number. Use a number between 0-65535."
						return root._reportValidation(Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("port_input_not_valid").arg(secondaryText)), saveMode)
					}
					return VenusOS.InputValidation_Result_OK
				}
				ListPortField {
					id: port

					// Read the entered value back from the DelegateComponent, so it
					// survives the delegate being destroyed and rebuilt when the row
					// scrolls out of the view and returns.
					secondaryText: portDC.secondaryText
					Component.onCompleted: portDC.field = port
					onSecondaryTextChanged: portDC.secondaryText = secondaryText
				}
			}

			DelegateComponent {
				id: unitDC
				property string secondaryText: "1"
				property ListTextField field
				function runValidation(saveMode) {
					if (field) {
						return field.runValidation(saveMode)
					}
					const valueAsInt = parseInt(secondaryText)
					if (isNaN(valueAsInt) || valueAsInt <= 0 || valueAsInt > 247) {
						//% "%1 is not a valid unit number. Use a number between 1-247."
						return root._reportValidation(Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("page_settings_fronius_unitid_invalid").arg(secondaryText)), saveMode)
					}
					return VenusOS.InputValidation_Result_OK
				}
				ListIntField {
					id: unit

					//% "Unit ID"
					text: qsTrId("page_settings_fronius_add_modbus_unitid")
					secondaryText: unitDC.secondaryText
					Component.onCompleted: unitDC.field = unit
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
