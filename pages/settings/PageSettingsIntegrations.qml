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

		model: DelegateComponentModel {
			DelegateComponent {
				SettingsListHeader {
					//% "Device Integrations"
					text: qsTrId("pagesettingsintegrations_device_integrations")
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "PV Inverters"
					text: qsTrId("pagesettingsintegrations_pv_inverters")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFronius.qml", {"title": text})
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "Energy meters via RS485"
					text: qsTrId("pagesettingsintegrations_energy_meters")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsCGwacsOverview.qml", {"title": text})
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "Modbus Devices"
					text: qsTrId("pagesettingsintegrations_modbus_devices")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbus.qml", {"title": text})
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "MQTT Devices"
					text: qsTrId("pagesettingsintegrations_mqtt_devices")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsMqttDevices.qml", {"title": text})
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "Shelly Devices"
					text: qsTrId("pagesettingsintegrations_shelly_devices")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsShelly.qml", {"title": text})
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "EEBUS Devices"
					text: qsTrId("pagesettingsintegrations_eebus_devices")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsEebus.qml", {"title": text})
				}
			}

			DelegateComponent {
				id: hasBluetoothSupportDC
				dataItem: VeQuickItem { uid: Global.venusPlatform.serviceUid + "/Network/HasBluetoothSupport" }
				preferredVisible: !!hasBluetoothSupportDC.dataItem.value
				ListNavigation {
					//% "Bluetooth Sensors"
					text: qsTrId("pagesettingsintegrations_bluetooth_sensors")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBleSensors.qml", {"title": text})

					VeQuickItem {
						id: hasBluetoothSupport
						uid: Global.venusPlatform.serviceUid + "/Network/HasBluetoothSupport"
					}
				}
			}

			DelegateComponent {
				preferredVisible: tankSensorsDC.preferredVisible
						|| relay0DC.preferredVisible
						|| digitalIoDC.preferredVisible
				SettingsListHeader {
					//% "Physical I/O"
					text: qsTrId("pagesettingsintegrations_physical_io")
				}
			}

			DelegateComponent {
				id: tankSensorsDC
				property VeQItemTableModel analogModel: VeQItemTableModel {
					uids: [ BackendConnection.serviceUidForType("adc") + "/Devices" ]
					flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
				}
				readonly property int rowCount: analogModel.rowCount
				preferredVisible: rowCount > 0
				ListNavigation {
					id: tankSensorsItem

					//% "Tank and Temperature Sensors"
					text: qsTrId("pagesettingsintegrations_tank_and_temperature_sensors")
					onClicked: Global.pageManager.pushPage(analogInputsComponent, {"title": text})

					Component {
						id: analogInputsComponent

						Page {
							GradientListView {
								model: tankSensorsDC.analogModel
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
			}

			DelegateComponent {
				id: relay0DC
				dataItem: VeQuickItem { uid: Global.system.serviceUid + "/SwitchableOutput/0/Name" }
				preferredVisible: relay0DC.dataItem.valid
				ListNavigation {
					id: relaysItem

					//% "Relays"
					text: qsTrId("pagesettingsintegrations_relays")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsRelay.qml", {"title": text})

					VeQuickItem {
						id: relay0
						uid: Global.system.serviceUid + "/SwitchableOutput/0/Name"
					}
				}
			}

			DelegateComponent {
				id: digitalIoDC
				property VeQItemSortTableModel digitalModel: VeQItemSortTableModel {
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
				readonly property int rowCount: digitalModel.rowCount
				preferredVisible: rowCount > 0
				ListNavigation {
					id: digitalIoItem

					//% "Digital I/O"
					text: qsTrId("pagesettingsintegrations_digital_io")
					onClicked: Global.pageManager.pushPage(digitalInputsComponent, {"title": text})

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
								model: digitalIoDC.digitalModel
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
			}

			DelegateComponent {
				SettingsListHeader {
					//% "Server Applications"
					text: qsTrId("pagesettingsintegrations_server_applications")
				}
			}

			DelegateComponent {
				ListMqttAccessSwitch { }
			}

			DelegateComponent {
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
			}

			DelegateComponent {
				id: osLargeFeaturesDC
				property bool largeEnabled: signalkItemDC.preferredVisible || nodeRedModeItemDC.preferredVisible
				SettingsListHeader {
					id: osLargeFeatures
					text: osLargeFeaturesDC.largeEnabled
						//% "Venus OS Large Features"
						? qsTrId("pagesettingsintegrations_venus_os_large_features")
						//% "Enable the Venus OS Large firmware to use Node-RED or Signal-K"
						: qsTrId("pagesettingsintegrations_venus_os_enable_large_features")
				}
			}

			DelegateComponent {
				id: signalkItemDC
				dataItem: VeQuickItem { uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled" }
				preferredVisible: signalkItemDC.dataItem.valid
				ListNavigation {
					id: signalk

					//% "Signal K"
					text: qsTrId("settings_large_signal_k")
					secondaryText: signalkItem.valid && signalkItem.value ? CommonWords.enabled : CommonWords.disabled
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsSignalK.qml", {"title": text })

					VeQuickItem {
						id: signalkItem
						uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
					}
				}
			}

			DelegateComponent {
				id: nodeRedModeItemDC
				dataItem: VeQuickItem { uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode" }
				preferredVisible: nodeRedModeItemDC.dataItem.valid
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
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsNodeRed.qml", {"title": text })

					VeQuickItem {
						id: nodeRedModeItem
						uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
					}
				}
			}

			DelegateComponent {
				preferredVisible: osLargeFeaturesDC.largeEnabled
				ListLink {
					//% "Venus OS Large Documentation"
					text: qsTrId("settings_venusos_large_documentation")
					url: "https://ve3.nl/vol"
				}
			}

			DelegateComponent {
				preferredVisible: osLargeFeaturesDC.largeEnabled
				ListLink {
					//% "Victron Community"
					text: qsTrId("settings_large_victron_community")
					url: "https://community.victronenergy.com"
				}
			}

			DelegateComponent {
				id: guiPluginsHeaderDC
				preferredVisible: GuiPluginLoader.plugins.length > 0
				SettingsListHeader {
					id: guiPluginsHeader

					//% "UI Plugins"
					text: qsTrId("pagesettingsintegrations_ui_plugins")
				}
			}

			DelegateComponent {
				preferredVisible: guiPluginsHeaderDC.preferredVisible
				SettingsColumn {
					width: parent ? parent.width : 0
					Repeater {
						model: GuiPluginModel { id: pluginModel }
						delegate: SettingsListNavigation {
							id: switchNavigationItem

							required property string name
							required property color color
							required property var integrations
							readonly property var pluginSettingsPageIntegration: {
								if (integrations !== null && integrations.length > 0) {
									for (let i = 0; i < integrations.length; ++i) {
										if (integrations[i].type === GuiPluginLoader.PluginSettingsPage) {
											return integrations[i]
										}
									}
								}
								return null
							}
							readonly property bool hasDeviceListIntegration: {
								if (integrations !== null && integrations.length > 0) {
									for (let i = 0; i < integrations.length; ++i) {
										if (integrations[i].type === GuiPluginLoader.DeviceListSettingsPage) {
											return true
										}
									}
								}
								return false
							}

							text: switchNavigationItem.name
							secondaryText: hasDeviceListIntegration
								   //% "Integrates with the device list"
								? qsTrId("pagesettingsintegrations_uiplugin_integrates_with_devicelist")
								: ""
							indicatorColor: switchNavigationItem.color
							pageSource: switchNavigationItem.pluginSettingsPageIntegration?.url ?? ""
							interactive: switchNavigationItem.pluginSettingsPageIntegration !== null
						}
					}
				}
			}
		}
	}
}
