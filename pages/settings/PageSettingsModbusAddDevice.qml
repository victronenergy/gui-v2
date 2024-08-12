/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP

Page {
	id: root

	property VeQuickItem devices

	//% "Add Modbus TCP/UDP device"
	title: qsTrId("add_modbus_tcp_udp_device")

	C.ButtonGroup {
		id: radioButtonGroup
	}

	GradientListView {
		model: ObjectModel {

			ListRadioButtonGroup {
				id: protocol

				optionModel: [
					//% "TCP"
					{ display: qsTrId("modbus_add_device_tcp"), value: 'tcp' },
					//% "UDP"
					{ display: qsTrId("modbus_add_device_udp"), value: 'udp' },
				]
				//% "Protocol"
				text: qsTrId("modbus_add_device_protocol")
				currentIndex: 0
				onOptionClicked: function(index) {
					currentIndex = index
				}
			}

			ListIpAddressField {
				id: ipAddress
			}

			ListPortField {
				id: port

				secondaryText: "502"
			}

			ListIntField {
				id: unit

				//% "Unit"
				text: qsTrId("modbus_add_device_unit")
				secondaryText: "1"
				validateInput: function() {
					const valueAsInt = parseInt(textField.text)
					if (isNaN(valueAsInt) || valueAsInt <= 0 || valueAsInt > 247) {
						//% "%1 is not a valid unit number. Use a number between 1-247."
						return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("modbus_add_unit_invalid").arg(textField.text))
					}
					return Utils.validationResult(VenusOS.InputValidation_Result_OK, "", valueAsInt)
				}
			}

			ListButton {
				secondaryText: CommonWords.add_device
				onClicked: {
					const fields = [ipAddress, port, unit]
					for (let i = 0; i < fields.length; ++i) {
						const resultStatus = fields[i].runValidation(VenusOS.InputValidation_ValidateAndSave)
						if (resultStatus !== VenusOS.InputValidation_Result_OK) {
							return
						}
					}

					const d = [protocol.currentValue, ipAddress.secondaryText, port.secondaryText, unit.secondaryText];
					let s = d.join(':');

					if (devices.value && devices.value.length) {
						s = devices.value + ',' + s;
					}

					devices.setValue(s);
					Global.pageManager.popPage()
				}
			}
		}
	}
}
