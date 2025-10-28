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
		model: VisibleItemModel {

			ListPortField {
				id: port
				secondaryText: "1502"
			}

			ListIntField {
				id: unit

				//% "Unit ID"
				text: qsTrId("page_settings_fronius_add_modbus_unitid")
				secondaryText: "1"
				validateInput: function() {
					const valueAsInt = parseInt(textField.text)
					if (isNaN(valueAsInt) || valueAsInt <= 0 || valueAsInt > 247) {
						//% "%1 is not a valid unit number. Use a number between 1-247."
						return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("page_settings_fronius_unitid_invalid").arg(textField.text))
					}
					return Utils.validationResult(VenusOS.InputValidation_Result_OK, "", valueAsInt)
				}
			}

			ListButton {
				//% "Add"
				secondaryText: qsTrId("page_settings_fronius_add_modbus_location_button")
				onClicked: {
					const fields = [port, unit]
					for (let i = 0; i < fields.length; ++i) {
						const resultStatus = fields[i].runValidation(VenusOS.InputValidation_ValidateAndSave)
						if (resultStatus !== VenusOS.InputValidation_Result_OK) {
							return
						}
					}

					let s = [port.secondaryText, unit.secondaryText].join(':');
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
