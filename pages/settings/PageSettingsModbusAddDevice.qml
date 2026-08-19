/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property VeQuickItem devices

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
				function runValidation(saveMode) {
					if (ipAddress) {
						return ipAddress.runValidation(saveMode)
					}
					const trimmed = secondaryText.trim()
					if (!trimmed.match(/^([0-9]{1,3}\.){3}[0-9]{1,3}$/)) {
						//% "'%1' is not a valid IP address."
						return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("ip_address_input_not_valid").arg(trimmed))
					}
					const groups = trimmed.split(".")
					for (let i = 0; i < groups.length; ++i) {
						const group = parseInt(groups[i])
						if (group < 0 || group >= 256) {
							//% "'%1' is not a valid IP address."
							return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("ip_address_input_not_valid").arg(trimmed))
						}
					}
					return Utils.validationResult(VenusOS.InputValidation_Result_OK)
				}
				ListIpAddressField {
					id: ipAddress
					Component.onCompleted: ipAddressDC.secondaryText = secondaryText
					onSecondaryTextChanged: ipAddressDC.secondaryText = secondaryText
				}
			}

			DelegateComponent {
				id: portDC
				property string secondaryText: "502"
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

					secondaryText: "502"
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
						return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("modbus_add_unit_invalid").arg(secondaryText))
					}
					return Utils.validationResult(VenusOS.InputValidation_Result_OK)
				}
				ListIntField {
					id: unit

					//% "Unit"
					text: qsTrId("modbus_add_device_unit")
					secondaryText: "1"
					Component.onCompleted: unitDC.secondaryText = secondaryText
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
