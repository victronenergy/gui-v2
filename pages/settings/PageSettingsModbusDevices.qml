/*
** Copyright (C) 202447 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

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
		delegate: ListQuantityGroupNavigation {
			id: modbusDeviceDelegate

			readonly property int deviceNumber: index + 1
			readonly property var deviceInfo: modelData.split(':')
			readonly property string protocol: deviceInfo[0].toUpperCase()
			readonly property string ipAddress: deviceInfo[1]
			readonly property string portNumber: deviceInfo[2]
			readonly property string unitAddress: deviceInfo[3]

			readonly property string addressText: "%1 %2".arg(protocol).arg(ipAddress) // eg. 'TCP 192.168.21.234'

			function showRemoveDialog() {
				Global.dialogLayer.open(removeDeviceDialog, {
					modbusDevice: modelData,
					//: %1=protocol, %2=IP address, %3=port number, %4=unit number
					//% "%1 %2:%3 (Unit %4)"
					description: qsTrId("settings_modbus_remove_description")
							.arg(protocol)
							.arg(ipAddress)
							.arg(portNumber)
							.arg(unitAddress)
			   })
			}

			//% "Device %1"
			text: qsTrId("page_settings_modbus_device_number").arg(deviceNumber)
			iconSource: "qrc:/images/icon_minus_32.svg"
			iconColor: Theme.color_ok
			quantityModel: QuantityObjectModel {
				QuantityObject { object: modbusDeviceDelegate; key: "addressText"; unit: VenusOS.Units_None }
				QuantityObject { object: modbusDeviceDelegate; key: "portNumber"; unit: VenusOS.Units_None }
				QuantityObject { object: modbusDeviceDelegate; key: "unitAddress"; unit: VenusOS.Units_None }
			}

			background: ListSettingBackground {
				indicatorColor: modbusDeviceDelegate.backgroundIndicatorColor

				ListPressArea {
					anchors.fill: parent
					enabled: modbusDeviceDelegate.clickable
					onClicked: modbusDeviceDelegate.showRemoveDialog()
				}
			}

			interactive: userHasWriteAccess
			Keys.enabled: Global.keyNavigationEnabled && interactive
			onClicked: showRemoveDialog()
		}
	}

	Component {
		id: removeDeviceDialog

		ModalWarningDialog {

			property var modbusDevice

			//% "Remove Modbus device?"
			title: qsTrId("page_settings_modbus_device_remove_device")
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
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
