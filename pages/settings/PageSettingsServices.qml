/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	GradientListView {
		model: ObjectModel {
			ListNavigationItem {
				//% "Modbus TCP"
				text: qsTrId("settings_services_modbus_tcp")
				secondaryText: modbus.value === 1 ? CommonWords.enabled : CommonWords.disabled
				showAccessLevel: VenusOS.User_AccessType_Installer
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsModbusTcp.qml", { title: text })
				}

				VeQuickItem {
					id: modbus
					uid: Global.systemSettings.serviceUid + "/Settings/Services/Modbus"
				}
			}

			ListSwitch {
				id: mqtt

				//% "MQTT on LAN (SSL)"
				text: qsTrId("settings_services_mqtt_on_lan_ssl")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/MqttLocal"
			}

			ListSwitch {
				id: mqttLocalInsecure

				//% "MQTT on LAN (Plain-text)"
				text: qsTrId("settings_services_mqtt_on_lan_insecure")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/MqttLocalInsecure"
				visible: mqtt.checked
			}

			ListSwitch {
				//% "Console on VE.Direct 1"
				text: qsTrId("settings_services_console_on_vedirect1")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Services/Console/Enabled"
				showAccessLevel: VenusOS.User_AccessType_SuperUser
			}

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: canInterface.value || []
					delegate: ListNavigationItem {
						text: modelData["name"] || ""
						onClicked: Global.pageManager.pushPage(canBusComponent, { title: text })

						Component {
							id: canBusComponent

							PageSettingsCanbus {
								gateway: modelData["interface"]
								canConfig: modelData["config"]
							}
						}
					}
				}

				VeQuickItem {
					id: canInterface
					uid: Global.venusPlatform.serviceUid + "/CanBus/Interfaces"
				}
			}

			ListSwitch {
				//% "CAN-bus over TCP/IP (Debug)"
				text: qsTrId("settings_services_canbus_over_tcpip_debug")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Socketcand"
				showAccessLevel: VenusOS.User_AccessType_Service
			}
		}
	}
}
