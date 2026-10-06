/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	// Status text is anchored to a slot that is always the switch width, so
	// Enabled and Disabled share a column on a switch row and a chevron row.
	component PluginEnableRow: ListSetting {
			id: row

			property string pluginTitle
			property bool pluginEnabled
			property bool hasSettingsPage
			property string settingsUrl

			signal enableToggled

			text: pluginTitle
			interactive: hasSettingsPage
			hasSubMenu: hasSettingsPage

			function openPage() {
				if (settingsUrl.length > 0)
					Global.pageManager.pushPage(settingsUrl, { title: pluginTitle })
			}

			function toggleEnabled() {
				if (checkWriteAccessLevel())
					enableToggled()
			}

			rightPadding: rightInset
			topPadding: topInset
			bottomPadding: bottomInset

			contentItem: Item {
				implicitHeight: Math.max(titleLabel.implicitHeight, enableSwitch.implicitHeight)

				Label {
					id: titleLabel

					anchors {
						left: parent.left
						right: statusLabel.left
						rightMargin: row.spacing
						verticalCenter: parent.verticalCenter
					}
					topPadding: Theme.geometry_listItem_content_verticalMargin
					bottomPadding: Theme.geometry_listItem_content_verticalMargin
					text: row.pluginTitle
					font: row.font
					elide: Text.ElideRight
				}

				SecondaryListLabel {
					id: statusLabel

					anchors {
						right: trailing.left
						rightMargin: row.spacing
						verticalCenter: parent.verticalCenter
					}
					text: row.pluginEnabled ? CommonWords.enabled : CommonWords.disabled
				}

				Item {
					id: trailing

					anchors {
						right: parent.right
						verticalCenter: parent.verticalCenter
					}
					width: enableSwitch.implicitWidth
					height: enableSwitch.implicitHeight

					Switch {
						id: enableSwitch

						anchors {
							right: parent.right
							verticalCenter: parent.verticalCenter
						}
						opacity: row.hasSettingsPage ? 0 : 1
						enabled: !row.hasSettingsPage
						checked: row.pluginEnabled
						focusPolicy: Qt.NoFocus
						leftInset: row.spacing
						rightInset: row.horizontalContentPadding
						leftPadding: leftInset
						rightPadding: rightInset
						onClicked: row.toggleEnabled()
					}

					CP.ColorImage {
						anchors {
							right: parent.right
							rightMargin: row.horizontalContentPadding
							verticalCenter: parent.verticalCenter
						}
						visible: row.hasSettingsPage
						source: "qrc:/images/icon_chevron_right_32.svg"
						color: Theme.color_listItem_forwardIcon
					}
				}
			}

			ListPressArea {
				anchors.fill: parent
				enabled: row.hasSettingsPage
				onClicked: row.openPage()
			}

			Keys.onSpacePressed: {
				if (hasSettingsPage)
					openPage()
				else
					toggleEnabled()
			}
			Keys.onRightPressed: {
				if (hasSettingsPage)
					openPage()
			}
	}

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
			SettingsListHeader {
				//% "Device integrations"
				text: qsTrId("pagesettingsintegrations_device_integrations")
			}

			ListNavigation {
				//% "PV inverters"
				text: qsTrId("pagesettingsintegrations_pv_inverters")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFronius.qml", {"title": text})
			}

			ListNavigation {
				//% "Energy meters via RS485"
				text: qsTrId("pagesettingsintegrations_energy_meters")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsCGwacsOverview.qml", {"title": text})
			}

			ListNavigation {
				//% "Modbus devices"
				text: qsTrId("pagesettingsintegrations_modbus_devices")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbus.qml", {"title": text})
			}

			ListNavigation {
				//% "MQTT devices"
				text: qsTrId("pagesettingsintegrations_mqtt_devices")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsMqttDevices.qml", {"title": text})
			}

			ListNavigation {
				//% "Shelly devices"
				text: qsTrId("pagesettingsintegrations_shelly_devices")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsShelly.qml", {"title": text})
			}

			ListNavigation {
				//% "EEBUS devices"
				text: qsTrId("pagesettingsintegrations_eebus_devices")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsEebus.qml", {"title": text})
			}

			ListNavigation {
				//% "Bluetooth sensors"
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

				//% "Tank and temperature sensors"
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
					uid: Global.system.serviceUid + "/SwitchableOutput/0/Name"
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
				//% "Server applications"
				text: qsTrId("pagesettingsintegrations_server_applications")
			}

			ListMqttAccessSwitch { }

			ListNavigation {
				//% "Modbus TCP server"
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
				readonly property bool largeEnabled: signalk.preferredVisible || nodeRed.preferredVisible
				text: largeEnabled
					//% "Venus OS Large features"
					? qsTrId("pagesettingsintegrations_venus_os_large_features")
					//% "Enable the Venus OS Large firmware to use Node-RED or Signal-K"
					: qsTrId("pagesettingsintegrations_venus_os_enable_large_features")
			}

			ListNavigation {
				id: signalk

				//% "Signal K"
				text: qsTrId("settings_large_signal_k")
				secondaryText: signalkItem.valid && signalkItem.value ? CommonWords.enabled : CommonWords.disabled
				preferredVisible: signalkItem.valid
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsSignalK.qml", {"title": text })

				VeQuickItem {
					id: signalkItem
					uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
				}
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

			ListLink {
				//% "Venus OS Large documentation"
				text: qsTrId("settings_venusos_large_documentation")
				url: "https://ve3.nl/vol"
				preferredVisible: osLargeFeatures.largeEnabled
			}

			ListLink {
				//% "Victron Community"
				text: qsTrId("settings_large_victron_community")
				url: "https://community.victronenergy.com"
				preferredVisible: osLargeFeatures.largeEnabled
			}

			SettingsListHeader {
				id: guiPluginsHeader

				//% "UI plugins"
				text: qsTrId("pagesettingsintegrations_ui_plugins")
				preferredVisible: GuiPluginLoader.plugins.length > 0
			}

			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: guiPluginsHeader.preferredVisible
				Repeater {
					model: GuiPluginModel { id: pluginModel }
					delegate: SettingsColumn {
						id: pluginColumn

						required property string name
						required property var integrations
						width: parent ? parent.width : 0

						// isPluginEnabled() is a function, so the row keeps its own copy
						// and refreshes it when that plugin's enable bit changes.
						property bool pluginEnabled: GuiPluginLoader.isPluginEnabled(name)

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

						Connections {
							target: GuiPluginLoader
							function onPluginEnabledChanged(changedName) {
								if (changedName === pluginColumn.name) {
									pluginColumn.pluginEnabled = GuiPluginLoader.isPluginEnabled(pluginColumn.name)
								}
							}
						}

						PluginEnableRow {
							pluginTitle: pluginColumn.name
							pluginEnabled: pluginColumn.pluginEnabled
							hasSettingsPage: pluginColumn.pluginSettingsPageIntegration !== null
							settingsUrl: String(pluginColumn.pluginSettingsPageIntegration?.url ?? "")
							onEnableToggled: GuiPluginLoader.setPluginEnabled(pluginColumn.name, !pluginColumn.pluginEnabled)
						}
					}
				}
			}
		}
	}
}
