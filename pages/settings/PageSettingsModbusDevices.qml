/*
** Copyright (C) 202447 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

Page {
	id: root

	property string settings: Global.systemSettings.serviceUid

	topRightButton: Global.systemSettings.canAccess(VenusOS.User_AccessType_Installer)
		? VenusOS.StatusBar_RightButton_Add
		: VenusOS.StatusBar_RightButton_None

	Connections {
		target: Global.mainView?.statusBar ?? null
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
		model: _devices.value ? _devices.value.split(',') : []
		delegate: ListSetting {
			id: modbusDeviceDelegate

			property int deviceNumber: index + 1
			property var deviceInfo: modelData.split(':')

			contentItem: RowLayout {
				function showRemoveDialog() {
					Global.dialogLayer.open(removeDeviceDialog, {
						modbusDevice: modelData,
						description: protocol.text +" " +
									ipAddress.text + ":" +
									portNumber.text +
									" (Unit " +
									unitAddress.text +
									")"
				   })
				}

				spacing: modbusDeviceDelegate.spacing

				Label {
					//% "Device %1"
					text: qsTrId("page_settings_modbus_device_number").arg(deviceNumber)
					font: modbusDeviceDelegate.font
					Layout.fillWidth: true
				}
				Label {
					id: protocol
					text: deviceInfo[0].toUpperCase() // eg. 'TCP'
					Layout.minimumWidth: Theme.geometry_modbus_device_protocol_width
				}
				Label {
					id: ipAddress
					text: deviceInfo[1] // IP address, eg. '192.168.21.234'
					Layout.minimumWidth: Theme.geometry_modbus_device_protocol_width
				}
				Label {
					id: portNumber
					text: deviceInfo[2] // port number, eg. 502
					Layout.minimumWidth: Theme.geometry_modbus_device_protocol_width
				}
				Label {
					id: unitAddress
					text: deviceInfo[3] // unit address
					Layout.minimumWidth: Theme.geometry_modbus_device_protocol_width
				}
				RemoveButton {
					visible: modbusDeviceDelegate.clickable
					onClicked: parent.showRemoveDialog()
				}
			}

			background: ListSettingBackground {
				indicatorColor: modbusDeviceDelegate.backgroundIndicatorColor

				ListPressArea {
					anchors.fill: parent
					onClicked: modbusDeviceDelegate.contentItem.showRemoveDialog()
				}
			}

			interactive: true
			Keys.onSpacePressed: modbusDeviceDelegate.contentItem.showRemoveDialog()
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
