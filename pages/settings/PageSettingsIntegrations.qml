/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			/*
			  The intention here was to provide a wizard helping to find the right setup process – As we are not there yet, let’s hide it for now

			ListNavigation {
				text: CommonWords.add_device
				icon.source: "qrc:/images/icon_plus_32.svg"
				icon.color: Theme.color_blue
				icon.width: 32
				icon.height: 32
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbusAddDevice.qml", {"title": text})
			}

			SettingsListHeader { }
			*/

			ListNavigation {
				//% "PV Inverters"
				text: qsTrId("pagesettingsintegrations_pv_inverters")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFronius.qml", {"title": text})
			}

			ListNavigation {
				//% "Energy meters via RS485"
				text: qsTrId("pagesettingsintegrations_energy_meters")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsCGwacsOverview.qml", {"title": text})
			}

			ListNavigation {
				//% "Modbus Devices"
				text: qsTrId("pagesettingsintegrations_modbus_devices")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbus.qml", {"title": text})
			}

			ListNavigation {
				//% "Bluetooth Sensors"
				text: qsTrId("pagesettingsintegrations_bluetooth_sensors")
				preferredVisible: !!hasBluetoothSupport.value
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBleSensors.qml", {"title": text})

				VeQuickItem {
					id: hasBluetoothSupport
					uid: Global.venusPlatform.serviceUid + "/Network/HasBluetoothSupport"
				}
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
				onClicked: Global.pageManager.pushPage(analogInputsComponent, {"title": text})

				VeQItemTableModel {
					id: analogModel
					uids: [ BackendConnection.serviceUidForType("adc") + "/Devices" ]
					flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
				}

				Component {
					id: analogInputsComponent

					Page {
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
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsRelay.qml", {"title": text})
				preferredVisible: relay0.valid

				VeQuickItem {
					id: relay0
					uid: Global.system.serviceUid + "/Relay/0/State"
				}
			}

			ListNavigation {
				id: digitalIoItem

				//% "Digital I/O"
				text: qsTrId("pagesettingsintegrations_digital_io")
				preferredVisible: digitalModel.rowCount > 0
				onClicked: Global.pageManager.pushPage(digitalInputsComponent, {"title": text})

				VeQItemSortTableModel {
					id: digitalModel
					sortColumn: childValues.sortValueColumn
					dynamicSortFilter: true
					filterFlags: VeQItemSortTableModel.FilterInvalid

					model: VeQItemChildModel {
						id: childValues

						model: VeQItemTableModel {
							uids: [ BackendConnection.serviceUidForType("digitalinputs") + "/Devices" ]
							flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
						}
						childId: "Label"
						sortDelegate: VeQItemSortDelegate {
							VeQuickItem {
								id: labelItem
								uid: buddy.uid + "/Label"
							}
							sortValue: labelItem.value || ""
						}
					}
				}

				Component {
					id: digitalInputsComponent

					Page {
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
								required property VeQItem item

								text: item.value || ""
								dataItem.uid: item.itemParent().uid + "/Type"
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
				//% "Modbus TCP Server"
				text: qsTrId("pagesettingsintegrations_modbus_tcp_server")
				secondaryText: modbusServerEnabled.value ? CommonWords.enabled : CommonWords.disabled
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbusTcp.qml", {"title": text}) // TODO - is this correct?

				VeQuickItem {
					id: modbusServerEnabled

					uid: Global.systemSettings.serviceUid + "/Settings/Services/Modbus"
				}
			}

			SettingsListHeader {
				id: osLargeFeatures

				//% "Venus OS Large Features"
				text: qsTrId("pagesettingsintegrations_venus_os_large_features")
				visible: signalk.preferredVisible || nodeRed.preferredVisible
			}

			PrimaryListLabel {
				//% "Note that the following features are not officially supported by Victron. Please turn to the Victron Community for questions."
				text: qsTrId("settings_large_features_not_offically_supported")
				preferredVisible: osLargeFeatures.visible
			}

			ListLink {
				//% "Documentation"
				text: qsTrId("settings_large_documentation")
				url: "https://ve3.nl/vol"
				preferredVisible: osLargeFeatures.visible
			}

			ListLink {
				//% "Victron Community"
				text: qsTrId("settings_large_victron_community")
				url: "https://community.victronenergy.com"
				preferredVisible: osLargeFeatures.visible
			}

			SettingsListHeader {
				preferredVisible: osLargeFeatures.visible
			}

			ListSwitch {
				id: signalk

				//% "Signal K"
				text: qsTrId("settings_large_signal_k")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
				preferredVisible: dataItem.valid
			}

			ListLink {
				//% "Access Signal K locally or via VRM"
				text: qsTrId("settings_large_access_signal_k")
				url: "http://venus.local:3000"
				preferredVisible: signalk.checked
			}

			ListNavigation {
				id: nodeRed

				//% "Node-RED"
				text: qsTrId("settings_large_node_red")
				secondaryText: {
					if (nodeRedModeItem.value === VenusOS.NodeRed_Mode_Disabled) {
						return CommonWords.disabled
					} else if (nodeRedModeItem.value === VenusOS.NodeRed_Mode_EnabledWithSafeMode) {
						return qsTrId("settings_large_enabled_safe_mode")
					} else if (nodeRedModeItem.value === VenusOS.NodeRed_Mode_Enabled) {
						return CommonWords.enabled
					} else if (nodeRedModeItem.value === VenusOS.NodeRed_Mode_EnabledWithSafeMode) {
						//% "Enabled (safe mode)"
						return qsTrId("settings_large_enabled_safe_mode")
					} else {
						return ""
					}
				}
				preferredVisible: nodeRedModeItem.valid
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsNodeRed.qml", {"title": text })

				VeQuickItem {
					id: nodeRedModeItem
					uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
				}
			}
		}
	}
}
