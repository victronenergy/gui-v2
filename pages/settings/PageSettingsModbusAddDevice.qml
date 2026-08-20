/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property VeQuickItem devices

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

	//% "Add Modbus TCP/UDP device"
	title: qsTrId("add_modbus_tcp_udp_device")

	ButtonGroup {
		id: radioButtonGroup
	}

	GradientListView {
		model: DelegateComponentModel {

			DelegateComponent {
				id: protocolDC
				property var optionModel: [
					//% "TCP"
					{ display: qsTrId("modbus_add_device_tcp"), value: "tcp" },
					//% "UDP"
					{ display: qsTrId("modbus_add_device_udp"), value: "udp" },
				]
				property int currentIndex: 0
				readonly property string currentValue: optionModel[currentIndex].value
				ListRadioButtonGroup {
					id: protocol

					optionModel: protocolDC.optionModel
					//% "Protocol"
					text: qsTrId("modbus_add_device_protocol")
					currentIndex: protocolDC.currentIndex
					onOptionClicked: function(index) {
						protocolDC.currentIndex = index
					}
				}
			}

			DelegateComponent {
				id: ipAddressDC
				property string secondaryText
				property ListTextField field
				function runValidation(saveMode) {
					if (field) {
						return field.runValidation(saveMode)
					}
					const trimmed = secondaryText.trim()
					if (!trimmed.match(/^([0-9]{1,3}\.){3}[0-9]{1,3}$/)) {
						//% "'%1' is not a valid IP address."
						return root._reportValidation(Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("ip_address_input_not_valid").arg(trimmed)), saveMode)
					}
					const groups = trimmed.split(".")
					for (let i = 0; i < groups.length; ++i) {
						const group = parseInt(groups[i])
						if (group < 0 || group >= 256) {
							//% "'%1' is not a valid IP address."
							return root._reportValidation(Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("ip_address_input_not_valid").arg(trimmed)), saveMode)
						}
					}
					return VenusOS.InputValidation_Result_OK
				}
				ListIpAddressField {
					id: ipAddress

					// Read the entered value back from the DelegateComponent. The
					// delegate is destroyed when the row scrolls out of the view and
					// rebuilt when it returns; without this it would come back with its
					// default and overwrite what the user typed.
					secondaryText: ipAddressDC.secondaryText
					Component.onCompleted: ipAddressDC.field = ipAddress
					onSecondaryTextChanged: ipAddressDC.secondaryText = secondaryText
				}
			}

			DelegateComponent {
				id: portDC
				property string secondaryText: "502"
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
						return root._reportValidation(Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("modbus_add_unit_invalid").arg(secondaryText)), saveMode)
					}
					return VenusOS.InputValidation_Result_OK
				}
				ListIntField {
					id: unit

					//% "Unit"
					text: qsTrId("modbus_add_device_unit")
					secondaryText: unitDC.secondaryText
					Component.onCompleted: unitDC.field = unit
					onSecondaryTextChanged: unitDC.secondaryText = secondaryText
					validateInput: function() {
						const valueAsInt = parseInt(secondaryText)
						if (isNaN(valueAsInt) || valueAsInt <= 0 || valueAsInt > 247) {
							//% "%1 is not a valid unit number. Use a number between 1-247."
							return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("modbus_add_unit_invalid").arg(secondaryText))
						}
						return Utils.validationResult(VenusOS.InputValidation_Result_OK, "", valueAsInt)
					}
				}
			}

			DelegateComponent {
				ListButton {
					secondaryText: CommonWords.add_device
					onClicked: {
						const fields = [ipAddressDC, portDC, unitDC]
						for (let i = 0; i < fields.length; ++i) {
							const resultStatus = fields[i].runValidation(VenusOS.InputValidation_ValidateAndSave)
							if (resultStatus !== VenusOS.InputValidation_Result_OK) {
								return
							}
						}

						const d = [protocolDC.currentValue, ipAddressDC.secondaryText, portDC.secondaryText, unitDC.secondaryText];
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
}
