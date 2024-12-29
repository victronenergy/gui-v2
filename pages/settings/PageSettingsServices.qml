/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: ObjectModel {

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: canInterface.value || []
					delegate: ListNavigation {
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
