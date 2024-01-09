/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Utils

Page {
	id: root

	property CmTechnology _tech: Connman.getTechnology("wifi")

	function _reload() {
		// TODO ideally this would be an QAbstractListModel that updates itself progressively,
		// instead of needing to reload the whole model.
		settingsListView.model = Connman.getServiceList("wifi")
	}

	C.StackView.onActivated: _reload()

	GradientListView {
		id: settingsListView

		header: ListTextItem {
			visible: settingsListView.count === 0
			text: {
				if (root._tech) {
					if (root._tech.powered) {
						//% "No access points"
						return qsTrId("settings_wifi_no_access_points")
					} else {
						root._tech.powered = true
					}
				}
				//% "No Wi-Fi adapter connected"
				return qsTrId("settings_wifi_no_wifi_adapter_connected")
			}
		}

		model: Connman.getServiceList("wifi")

		delegate: ListNavigationItem {
			id: wifiPoint

			property CmService service: Connman.getService(modelData)

			text: service ? (service.name ? service.name : "[" + service.ethernet["Address"] + "]") : ""
			secondaryText: Utils.connmanServiceState(service)
			primaryLabel.leftPadding: Theme.geometry_statusBar_button_icon_width + Theme.geometry_listItem_content_spacing

			CP.ColorImage {
				anchors {
					left: wifiPoint.primaryLabel.left
					verticalCenter: wifiPoint.primaryLabel.verticalCenter
				}
				source: "/images/icon_checkmark_48.svg"
				width: Theme.geometry_statusBar_button_icon_width
				height: Theme.geometry_statusBar_button_icon_height
				color: Theme.color_green
				visible: wifiPoint.service && wifiPoint.service.favorite
			}

			onClicked: {
				Global.pageManager.pushPage(wifiPointComponent, { title: service.name })
			}

			Component {
				id: wifiPointComponent

				PageSettingsTcpIp {
					path: modelData
					service: wifiPoint.service
					technologyType: "wifi"
				}
			}
		}
	}

	Connections {
		target: Connman
		function onServiceListChanged() {
			if (!!Global.pageManager && Global.pageManager.currentPage === root) {
				root._reload()
			}
		}
	}

	Timer {
		id: scanTimer
		interval: 10000
		running: root.animationEnabled
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			if (root._tech) {
				root._tech.scan()
			}
		}
	}

	// This timer is added because when a wifi service is in failure, it will only leave this
	// state when a user presses connect or when the service is removed because wpa_supplicant
	// did not see the service for 3 minutes. This will not happen while we continue to scan
	// every 10 seconds, but the scanning does make sense while we are in this menu. So it
	// was decided to exit this menu when a user did nothing for 5 mminutes. In the end,
	// this will result in a removal of a service in failure with a possible automatic
	// reconnect when the service is seen again because of the automatic scan by connman.
	Timer {
		id: exitMenuTimer
		interval: 5 * 60 * 1000
		running: scanTimer.running
		repeat: false
		triggeredOnStart: false
		onTriggered: {
			Global.pageManager.popPage()
		}
	}

	MouseArea {
		anchors.fill: parent
		onPressed: function(mouse) {
			if (exitMenuTimer.running) {
				exitMenuTimer.restart()
			}
			mouse.accepted = false
		}
	}
}
