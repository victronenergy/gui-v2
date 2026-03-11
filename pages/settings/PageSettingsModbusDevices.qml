/*
** Copyright (C) 202447 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	function _showRemoveDialog(deviceData, protocol, ipAddress, portNumber, unitAddress) {
		Global.dialogLayer.open(removeDeviceDialog, {
			modbusDevice: deviceData,
			//% "%1 %2:%3 (Unit %4)"
			description: qsTrId("page_settings_modbus_remove_device_description")
					.arg(protocol)
					.arg(ipAddress)
					.arg(portNumber)
					.arg(unitAddress)
		})
	}

	VeQuickItem {
		id: _devices

		uid: Global.systemSettings.serviceUid + "/Settings/ModbusClient/tcp/Devices"
		// eg: [[tcp,192.168.20.75,502,1],[tcp,192.168.21.234,502,1],[tcp,192.168.21.43,502,1]]
	}

	GradientListView {
		header: SettingsColumn {
			width: parent?.width ?? 0
			bottomPadding: addDevice.visible ? spacing : 0

			ListNavigation {
				id: addDevice
				text: CommonWords.add_modbus_device
				iconSource: "qrc:/images/icon_plus_32.svg"
				iconColor: Theme.color_ok
				showAccessLevel: VenusOS.User_AccessType_Installer
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbusAddDevice.qml", { devices: _devices } )
			}

			SettingsListHeader {
				visible: addDevice.visible
			}
		}
		model: _devices.value ? _devices.value.split(',') : []
		delegate: ListSetting {
			id: modbusDeviceDelegate

			readonly property int deviceNumber: index + 1
			readonly property var deviceInfo: modelData.split(':')
			readonly property string protocol: deviceInfo[0].toUpperCase()
			readonly property string ipAddress: deviceInfo[1]
			readonly property string portNumber: deviceInfo[2]
			readonly property string unitAddress: deviceInfo[3]

			function click() {
				if (clickable) {
					root._showRemoveDialog(modelData, protocol, ipAddress, portNumber, unitAddress)
				}
			}

			contentItem: Item {
				Label {
					anchors {
						left: parent.left
						right: contentRow.left
						rightMargin: modbusDeviceDelegate.spacing
						verticalCenter: parent.verticalCenter
					}

					//% "Device %1"
					text: qsTrId("page_settings_modbus_device_number").arg(deviceNumber)
					font: modbusDeviceDelegate.font
					elide: Text.ElideRight
				}

				RowLayout {
					id: contentRow

					anchors {
						right: parent.right
						verticalCenter: parent.verticalCenter
					}
					spacing: modbusDeviceDelegate.spacing

					Label {
						id: ipAddressLabel
						text: "%1 %2".arg(modbusDeviceDelegate.protocol).arg(modbusDeviceDelegate.ipAddress) // eg. 'TCP 192.168.21.234'
						font.pixelSize: Theme.font_size_body2
						color: Theme.color_listItem_secondaryText
					}

					Rectangle {
						width: Theme.geometry_listItem_separator_width
						height: ipAddressLabel.height
						color: Theme.color_listItem_separator
					}

					Label {
						text: modbusDeviceDelegate.portNumber
						font.pixelSize: Theme.font_size_body2
						color: Theme.color_listItem_secondaryText
						Layout.minimumWidth: Theme.geometry_modbus_device_protocol_width
					}

					Rectangle {
						width: Theme.geometry_listItem_separator_width
						height: ipAddressLabel.height
						color: Theme.color_listItem_separator
					}

					Label {
						text: modbusDeviceDelegate.unitAddress
						font.pixelSize: Theme.font_size_body2
						color: Theme.color_listItem_secondaryText
						Layout.minimumWidth: Theme.geometry_modbus_device_protocol_width
					}

					CP.ColorImage {
						source: "qrc:/images/icon_minus_32.svg"
						color: Theme.color_ok
						visible: modbusDeviceDelegate.clickable
					}
				}
			}

			background: ListSettingBackground {
				indicatorColor: modbusDeviceDelegate.backgroundIndicatorColor

				ListPressArea {
					anchors.fill: parent
					enabled: modbusDeviceDelegate.clickable
					onClicked: modbusDeviceDelegate.click()
				}
			}

			interactive: userHasWriteAccess
			Keys.onSpacePressed: click()
		}
	}

	Component {
		id: removeDeviceDialog

		ModalWarningDialog {

			property var modbusDevice

			//% "Remove Modbus device?"
			title: qsTrId("page_settings_modbus_device_remove_device")
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
			height: Theme.geometry_modalDialog_height_small
			icon.color: Theme.color_orange
			acceptText: CommonWords.remove

			onAccepted: {
				const addresses = _devices.value ? _devices.value.split(',') : []
				for (let i = 0; i < addresses.length; ++i) {
					if (addresses[i] === modbusDevice) {
						addresses.splice(i, 1)
						_devices.setValue(addresses.join(','))
						break
					}
				}
			}
		}
	}
}
