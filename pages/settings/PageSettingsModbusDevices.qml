/*
** Copyright (C) 202447 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP

Page {
	id: root

	property string settings: Global.systemSettings.serviceUid

	topRightButton: VenusOS.StatusBar_RightButton_Add

	Connections {
		target: !!Global.pageManager ? Global.pageManager.statusBar : null
		enabled: root.isCurrentPage

		function onRightButtonClicked() {
			Global.pageManager.pushPage("/pages/settings/PageSettingsModbusAddDevice.qml", { devices: _devices } )
		}
	}

	VeQuickItem {
		id: _devices

		uid: root.settings + "/Settings/ModbusClient/tcp/Devices"
		// eg: [[tcp,192.168.20.75,502,1],[tcp,192.168.21.234,502,1],[tcp,192.168.21.43,502,1]]
	}


	GradientListView {
		header: PrimaryListLabel {
			horizontalAlignment: Text.AlignHCenter
			preferredVisible: !_devices.value
			//% "No Modbus devices saved"
			text: qsTrId("settings_modbus_no_devices_saved")
		}
		model: VisibleItemModel {
			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: modbusDeviceRepeater.count > 0

				Repeater {
					id: modbusDeviceRepeater
					model: _devices.value ? _devices.value.split(',') : []
					delegate: ListItem {
						property int deviceNumber: index + 1
						property var deviceInfo: modelData.split(':')

						//% "Device %1"
						text: qsTrId("page_settings_modbus_device_number").arg(deviceNumber)
						content.spacing: 30
						content.children: [
							Label {
								id: protocol

								anchors.verticalCenter: !!parent ? parent.verticalCenter : undefined
								text: deviceInfo[0].toUpperCase() // eg. 'TCP'
								width: Math.max(implicitWidth, Theme.geometry_modbus_device_protocol_width)
							},
							Label {
								id: ipAddress

								anchors.verticalCenter: !!parent ? parent.verticalCenter : undefined
								text: deviceInfo[1] // IP address, eg. '192.168.21.234'
								width: Math.max(implicitWidth, Theme.geometry_modbus_device_ip_address_width)
							},
							Label {
								id: portNumber

								anchors.verticalCenter: !!parent ? parent.verticalCenter : undefined
								text: deviceInfo[2] // port number, eg. 502
								width: Math.max(implicitWidth, Theme.geometry_modbus_device_protocol_width)
							},
							Label {
								id: unitAddress

								anchors.verticalCenter: !!parent ? parent.verticalCenter : undefined
								text: deviceInfo[3] // unit address
								width: Math.max(implicitWidth, Theme.geometry_modbus_device_protocol_width)
							},
							RemoveButton {
								id: removeButton
								onClicked: Global.dialogLayer.open(removeDeviceDialog,
																   {
																	   modbusDevice: modelData,
																	   description: protocol.text +" " +
																					ipAddress.text + ":" +
																					portNumber.text +
																					" (Unit " +
																					unitAddress.text +
																					")"
																   })
							}
						]

						Keys.onSpacePressed: removeButton.clicked()
						Keys.enabled: Global.keyNavigationEnabled
					}
				}
			}
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
