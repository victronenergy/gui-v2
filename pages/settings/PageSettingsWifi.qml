/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	onIsCurrentPageChanged: if (isCurrentPage) servicesItem.update()

	VeQuickItem {
		id: servicesItem

		uid: Global.venusPlatform.serviceUid + "/Network/Services"

		// TODO ideally this would be an QAbstractListModel that updates itself progressively,
		// instead of needing to reload the whole model.
		onValueChanged: if (root.isCurrentPage) update()

		function update() {
			if (!isValid || !scanItem.isValid) {
				model.clear()
				return
			}

			/*
				Following config is provided for each network item:

				"Victron": {
					"Service": "/net/connman/service/wifi_5cc5633c7cfa_56696374726f6e_managed_ieee8021x",
					"State": "Disconnected",
					"Strength": "45",
					"Secured": "yes",
					"Favorite": "yes",
					"Address": "192.168.68.62",
					"Gateway": "",
					"Method": "manual",
					"Netmask": "255.255.252.0",
					"Mac": "5C:C5:63:3C:7C:FA",
					"Nameservers": ["193.12.34.56", "193.12.34.57"]
				}
			*/
			const wifis = JSON.parse(value)["wifi"]

			const services = Object.values(wifis)
			  .filter((object) => object && typeof object === "object")
			  .map((object) => object["Service"])

			// Remove networks that have been dropped
			for (var i = 0; i < model.count; i++) {
				if (services.indexOf(model.get(i).service) == -1) {
					model.remove(i)
				}
			}

			i = 0
			for (const [network, details] of Object.entries(wifis)) {
				let found = false
				for (let j = 0; j < model.count; j++) {
					let service = details["Service"]
					// Update existing networks
					if (service && service === model.get(j).service) {
						found = true
						model.set(i, {
									  "network": network,
									  "service": details["Service"],
									  "state": details["State"],
									  "favorite": details["Favorite"] === "yes"
								  })
						break
					}
				}

				// Insert newly discovered networks
				if (!found) {
					// Services are sorted by favorite and signal strength, try to maintain order
					model.insert(i, {
									 "network": network,
									 "service": details["Service"],
									 "state": details["State"],
									 "favorite": details["Favorite"] === "yes"
								 })
				}
				i++
			}
		}
	}

	VeQuickItem {
		id: scanItem
		uid: Global.venusPlatform.serviceUid +  "/Network/Wifi/Scan"
	}

	GradientListView {
		id: settingsListView

		model: ListModel { id: model }

		header: Column {
			width: parent.width
			ListSwitch {
				//% "Create access point"
				text: qsTrId("settings_wifi_create_ap")
				checked: accessPoint.value === 1
				allowed: defaultAllowed && accessPoint.isValid
				updateOnClick: false

				onClicked: {
					if (checked) {
						Global.dialogLayer.open(confirmApDialogComponent)
					} else {
						accessPoint.setValue(1)
					}
				}

				VeQuickItem {
					id: accessPoint
					uid: Global.venusPlatform.serviceUid + "/Services/AccessPoint/Enabled"
				}

				Component {
					id: confirmApDialogComponent

					ModalWarningDialog {
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						//% "Disable Access Point"
						title: qsTrId("settings_wifi_disable_ap")
						//% "Are you sure that you want to disable the access point?"
						description: qsTrId("settings_wifi_disable_ap_are_you_sure")

						onAccepted: {
							accessPoint.setValue(0)
						}
					}
				}
			}

			ListSectionHeader {
				//% "Wi-Fi networks"
				text: qsTrId("settings_wifi_networks")
				allowed: scanItem.isValid && accessPoint.isValid
			}

			ListLabel {
				allowed: settingsListView.count === 0
				text: scanItem.isValid && servicesItem.isValid
						//% "No access points"
					  ? qsTrId("settings_wifi_no_access_points")
						//% "No Wi-Fi adapter connected"
					  : qsTrId("settings_wifi_no_wifi_adapter_connected")
			}
		}

		delegate: ListNavigationItem {
			id: delagate

			//% "[Hidden]"
			text: model.network ? model.network : qsTrId("settings_tcpip_hidden")
			secondaryText: Utils.connmanServiceState(model.state)
			primaryLabel.leftPadding: Theme.geometry_icon_size_medium + Theme.geometry_listItem_content_spacing

			CP.ColorImage {
				anchors {
					left: delagate.primaryLabel.left
					verticalCenter: delagate.primaryLabel.verticalCenter
				}
				source: "qrc:/images/icon_checkmark_32.svg"
				color: Theme.color_green
				visible: model.favorite
			}

			onClicked: Global.pageManager.pushPage(wifiPointComponent)

			Component {
				id: wifiPointComponent

				PageSettingsTcpIp {
					title: delagate.text
					service: model.service
					network: model.network
					tech: "wifi"
				}
			}
		}
	}

	Timer {
		id: scanTimer
		interval: 10000
		running: root.animationEnabled
		repeat: true
		triggeredOnStart: true
		onTriggered: scanItem.setValue(1)
	}

	// This timer is added because when a wifi service is in failure, it will only leave this
	// state when a user presses connect or when the service is removed because wpa_supplicant
	// did not see the service for 3 minutes. This will not happen while we continue to scan
	// every 10 seconds, but the scanning does make sense while we are in this menu. So it
	// was decided to exit this menu when a user did nothing for 5 minutes. In the end,
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
