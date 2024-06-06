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

				function valid() {
					const digits = secondaryText.split('.')
					return ( digits.length === 4 &&
							parseInt(digits[0]) < 256 &&
							parseInt(digits[1]) < 256 &&
							parseInt(digits[2]) < 256 &&
							parseInt(digits[3]) < 256 &&
							secondaryText !== "0.0.0.0" )
				}

				text: CommonWords.ip_address
			}

			ListTextField {
				id: port

				function valid() {
					const valueAsInt = parseInt(secondaryText)
					return ((valueAsInt > 0) && (valueAsInt < 65535))
				}

				//% "Port"
				text: qsTrId("modbus_add_device_port")
				secondaryText: "502"
				textField.validator: RegularExpressionValidator { regularExpression: /[0-9]{1,5}/ }
				textField.inputMethodHints: Qt.ImhDigitsOnly
			}

			ListTextField {
				id: unit

				function valid() {
					const valueAsInt = parseInt(secondaryText)
					return ((valueAsInt > 0) && (valueAsInt <= 247))
				}

				//% "Unit"
				text: qsTrId("modbus_add_device_unit")
				secondaryText: "1"
				textField.validator: RegularExpressionValidator { regularExpression: /[0-9]{1,5}/ }
				textField.inputMethodHints: Qt.ImhDigitsOnly
			}

			ListButton {
				secondaryText: CommonWords.add_device
				onClicked: {
					if (!ipAddress.valid()) {
						//% "Invalid IP address"
						Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("modbus_invalid_ip_address"), 5000)
						return
					}

					if (!port.valid()) {
						//% "Invalid port number"
						Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("modbus_invalid_port_number"), 5000)
						return
					}

					if (!unit.valid()) {
						//% "Invalid unit address"
						Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("modbus_invalid_unit_address"), 5000)
						return
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
