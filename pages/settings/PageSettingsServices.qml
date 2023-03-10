/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListPage {
	id: root

	listView: GradientListView {
		model: ObjectModel {
			ListNavigationItem {
				//% "Modbus TCP"
				text: qsTrId("settings_services_modbus_tcp")
				secondaryText: modbus.value === 1 ? CommonWords.enabled : CommonWords.disabled
				showAccessLevel: VenusOS.User_AccessType_Installer
				listPage: root
				listIndex: ObjectModel.index
				onClicked: {
					listPage.navigateTo("/pages/settings/PageSettingsModbusTcp.qml", { title: text }, listIndex)
				}

				DataPoint {
					id: modbus
					source: "com.victronenergy.settings/Settings/Services/Modbus"
				}
			}

			ListSwitch {
				id: mqtt

				//% "MQTT on LAN (SSL)"
				text: qsTrId("settings_services_mqtt_on_lan_ssl")
				dataSource: "com.victronenergy.settings/Settings/Services/MqttLocal"
			}

			ListSwitch {
				id: mqttLocalInsecure

				//% "MQTT on LAN (Plain-text)"
				text: qsTrId("settings_services_mqtt_on_lan_insecure")
				dataSource: "com.victronenergy.settings/Settings/Services/MqttLocalInsecure"
				visible: mqtt.checked
			}

			ListSwitch {
				//% "Console on VE.Direct 1"
				text: qsTrId("settings_services_console_on_vedirect1")
				dataSource: "com.victronenergy.platform/Services/Console/Enabled"
				showAccessLevel: VenusOS.User_AccessType_SuperUser
			}

			Column {
				id: interfacesColumn
				width: parent ? parent.width : 0
				property int modelIdx: ObjectModel.index

				Repeater {
					model: canInterface.value || []
					delegate: ListNavigationItem {
						text: modelData["name"] || ""
						listPage: root
						listIndex: interfacesColumn.modelIdx
						onClicked: listPage.navigateTo(canBusComponent, { title: text }, listIndex)

						Component {
							id: canBusComponent

							PageSettingsCanbus {
								gateway: modelData["interface"]
								canConfig: modelData["config"]
							}
						}
					}
				}

				DataPoint {
					id: canInterface
					source: "com.victronenergy.platform/CanBus/Interfaces"
				}
			}

			ListSwitch {
				//% "CAN-bus over TCP/IP (Debug)"
				text: qsTrId("settings_services_canbus_over_tcpip_debug")
				dataSource: "com.victronenergy.settings/Settings/Services/Socketcand"
				showAccessLevel: VenusOS.User_AccessType_Service
			}
		}
	}
}
