/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property bool allModificationsEnabled: allModificationsEnabledItem.valid && allModificationsEnabledItem.value === 1

	VeQuickItem {
		id: allModificationsEnabledItem
		uid: Global.systemSettings.serviceUid + "/Settings/System/ModificationChecks/AllModificationsEnabled"
	}

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			/*
			  The intention here was to provide a wizard helping to find the right setup process – As we are not there yet, let’s hide it for now

			ListNavigation {
				id: addDeviceItem
				text: CommonWords.add_device
				icon.source: "qrc:/images/icon_plus_32.svg"
				icon.color: Theme.color_blue
				icon.width: 32
				icon.height: 32
				onClicked: Global.pageManager.pushPage(pageSettingsModbusAddDevice)
				Component { id: pageSettingsModbusAddDevice; PageSettingsModbusAddDevice { title: addDeviceItem.text } }
			}

			SettingsListHeader { }
			*/

			ListNavigation {
				id: invertersItem
				//% "PV Inverters"
				text: qsTrId("pagesettingsintegrations_pv_inverters")
				onClicked: Global.pageManager.pushPage(pageSettingsFronius)
				Component { id: pageSettingsFronius; PageSettingsFronius { title: invertersItem.text } }
			}

			ListNavigation {
				id: rs485EmsItem
				//% "Energy meters via RS485"
				text: qsTrId("pagesettingsintegrations_energy_meters")
				onClicked: Global.pageManager.pushPage(pageSettingsCGwacsOverview)
				Component { id: pageSettingsCGwacsOverview; PageSettingsCGwacsOverview { title: rs485EmsItem.text } }
			}

			ListNavigation {
				id: modbusDevicesItem
				//% "Modbus Devices"
				text: qsTrId("pagesettingsintegrations_modbus_devices")
				onClicked: Global.pageManager.pushPage(pageSettingsModbus)
				Component { id: pageSettingsModbus; PageSettingsModbus { title: modbusDevicesItem.text } }
			}

			ListNavigation {
				id: bluetoothSensorsItem
				//% "Bluetooth Sensors"
				text: qsTrId("pagesettingsintegrations_bluetooth_sensors")
				preferredVisible: !!hasBluetoothSupport.value
				onClicked: Global.pageManager.pushPage(pageSettingsBleSensors)

				VeQuickItem {
					id: hasBluetoothSupport
					uid: Global.venusPlatform.serviceUid + "/Network/HasBluetoothSupport"
				}

				Component { id: pageSettingsBleSensors; PageSettingsBleSensors { title: bluetoothSensorsItem.text } }
			}

			SettingsListHeader {
				//% "Physical I/O"
				text: qsTrId("pagesettingsintegrations_physical_io")
				preferredVisible: tankSensorsItem.preferredVisible
					|| relaysItem.preferredVisible
					|| digitalIoItem.preferredVisible
			}

			ListNavigation {
				id: tankSensorsItem

				//% "Tank and Temperature Sensors"
				text: qsTrId("pagesettingsintegrations_tank_and_temperature_sensors")
				preferredVisible: analogModel.rowCount > 0
				onClicked: Global.pageManager.pushPage(analogInputsComponent)

				VeQItemTableModel {
					id: analogModel
					uids: [ BackendConnection.serviceUidForType("adc") + "/Devices" ]
					flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
				}

				Component {
					id: analogInputsComponent

					Page {
						title: tankSensorsItem.text
						GradientListView {
							model: analogModel
							delegate: ListSwitch {
								text: switchLabel.value || ""
								dataItem.uid: model.uid + "/Function"

								VeQuickItem {
									id: switchLabel
									uid: model.uid + "/Label"
								}
							}
						}
					}
				}
			}

			ListNavigation {
				id: relaysItem

				//% "Relays"
				text: qsTrId("pagesettingsintegrations_relays")
				onClicked: Global.pageManager.pushPage(pageSettingsRelay)
				preferredVisible: relay0.valid

				VeQuickItem {
					id: relay0
					uid: Global.system.serviceUid + "/Relay/0/State"
				}

				Component { id: pageSettingsRelay; PageSettingsRelay { title: relaysItem.text } }
			}

			ListNavigation {
				id: digitalIoItem

				//% "Digital I/O"
				text: qsTrId("pagesettingsintegrations_digital_io")
				preferredVisible: digitalModel.rowCount > 0
				onClicked: Global.pageManager.pushPage(digitalInputsComponent)

				VeQItemSortTableModel {
					id: digitalModel
					filterRegExp: "/[1-9]$"
					model: VeQItemTableModel {
						uids: [ Global.systemSettings.serviceUid + "/Settings/DigitalInput" ]
						flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
					}
				}

				Component {
					id: digitalInputsComponent

					Page {
						title: digitalIoItem.text
						readonly property var delegateOptionModel: [
							VenusOS.DigitalInput_Type_Disabled,
							VenusOS.DigitalInput_Type_PulseMeter,
							VenusOS.DigitalInput_Type_DoorAlarm,
							VenusOS.DigitalInput_Type_BilgePump,
							VenusOS.DigitalInput_Type_BilgeAlarm,
							VenusOS.DigitalInput_Type_BurglarAlarm,
							VenusOS.DigitalInput_Type_SmokeAlarm,
							VenusOS.DigitalInput_Type_FireAlarm,
							VenusOS.DigitalInput_Type_CO2Alarm,
							VenusOS.DigitalInput_Type_Generator,
							VenusOS.DigitalInput_Type_TouchInputControl
						].map(function(v) { return { value: v, display: VenusOS.digitalInput_typeToText(v)} } )

						GradientListView {
							model: digitalModel

							delegate: ListRadioButtonGroup {
								//: %1 = number of the digital input
								//% "Digital input %1"
								text: qsTrId("settings_io_digital_input").arg(model.uid.split('/').pop())
								dataItem.uid: model.uid + "/Type"
								optionModel: delegateOptionModel
							}
						}
					}
				}
			}

			SettingsListHeader {
				//% "Server Applications"
				text: qsTrId("pagesettingsintegrations_server_applications")
			}

			ListMqttAccessSwitch { }

			ListNavigation {
				id: modbusTcpServerItem
				//% "Modbus TCP Server"
				text: qsTrId("pagesettingsintegrations_modbus_tcp_server")
				secondaryText: modbusServerEnabled.value ? CommonWords.enabled : CommonWords.disabled
				onClicked: Global.pageManager.pushPage(pageSettingsModbusTcp)

				VeQuickItem {
					id: modbusServerEnabled

					uid: Global.systemSettings.serviceUid + "/Settings/Services/Modbus"
				}

				Component { id: pageSettingsModbusTcp; PageSettingsModbusTcp { title: modbusTcpServerItem.text } }
			}

			SettingsListHeader {
				id: osLargeFeatures

				//% "Venus OS Large Features"
				text: qsTrId("pagesettingsintegrations_venus_os_large_features")
				visible: signalk.preferredVisible || nodeRed.preferredVisible
			}

			PrimaryListLabel {
				//% "Note that the following features are not officially supported by Victron. Please turn to community.victronenergy.com for questions.\n\nDocumentation at https://ve3.nl/vol"
				text: qsTrId("settings_large_features_not_offically_supported")
				preferredVisible: osLargeFeatures.visible
			}

			PrimaryListLabel {
				text: CommonWords.all_modifications_disabled
				preferredVisible: osLargeFeatures.visible && !root.allModificationsEnabled
			}

			ListSwitch {
				id: signalk

				//% "Signal K"
				text: qsTrId("settings_large_signal_k")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
				enabled: userHasWriteAccess && root.allModificationsEnabled
				preferredVisible: dataItem.valid
			}

			PrimaryListLabel {
				//% "Access Signal K at http://venus.local:3000 and via VRM."
				text: qsTrId("settings_large_access_signal_k")
				preferredVisible: signalk.checked
			}

			ListNavigation {
				id: nodeRed

				//% "Node-RED"
				text: qsTrId("settings_large_node_red")
				preferredVisible: nodeRedModeItem.valid
				onClicked: Global.pageManager.pushPage(pageSettingsNodeRed)

				VeQuickItem {
					id: nodeRedModeItem
					uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
				}

				Component { id: pageSettingsNodeRed; PageSettingsNodeRed { title: nodeRed.text } }
			}
		}
	}
}
