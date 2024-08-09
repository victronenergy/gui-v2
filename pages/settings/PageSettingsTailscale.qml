/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string tailscaleServiceUid: BackendConnection.serviceUidForType("tailscale")

	property int connectState: stateItem.isValid ? stateItem.value : 0

	property string loginLink: loginItem.isValid ? loginItem.value : ""
	property string loginLinkQrCode: loginItemQrCode.isValid ? loginItemQrCode.value : ""
	property string serviceState: getState()

	property bool tailscaleEnabled: switchTailscaleEnabled.checked
	property bool tailscaleConnected: stateItem.isValid && tailscaleEnabled && connectState == 100

	function getState() {
		let returnValue

		// check if tailscale-backend is not running
		if (!stateItem.isValid) {
			//% "Tailscale backend service not running yet, please wait..."
			returnValue = qsTrId("settings_tailscale_tailscale_control_service_not_running")
		// check if tailscale-backend is not running or tailscale is disabled
		} else if (!stateItem.isValid || !tailscaleEnabled) {
			returnValue = ""
		} else if (tailscaleConnected) {
			returnValue = ""
		} else if (connectState == 0) {
			returnValue = ""
		} else if (connectState == 1) {
			//% "Starting..."
			returnValue = qsTrId("settings_tailscale_starting")
		} else if (connectState == 2 || connectState == 3) {
			//% "Tailscale starting..."
			returnValue = qsTrId("settings_tailscale_tailscale_starting")
		} else if (connectState == 4) {
			//% "This GX device is logged out of Tailscale.\n\nPlease wait or check your internet connection and try again."
			returnValue = qsTrId("settings_tailscale_logged_out")
		} else if (connectState == 5) {
			//% "Waiting for a response from Tailscale..."
			returnValue = qsTrId("settings_tailscale_waiting_for_a_response")
		} else if (connectState == 6) {
			//% "Connect this GX device to your Tailscale account by opening this link:"
			returnValue = qsTrId("settings_tailscale_connect_to_tailscale_account") + "\n\n" + loginLink
		} else {
			//% "Unknown state:"
			returnValue = qsTrId("settings_tailscale_unknown_state") + " " + connectState
		}

		if (tailscaleEnabled && !tailscaleConnected && connectState != 6 && errorMessageItem.isValid && errorMessageItem.value !== "") {
			returnValue += "\n\nERROR: " + errorMessageItem.value
		}

		return (returnValue)
	}

	VeQuickItem {
		id: errorMessageItem
		uid: tailscaleServiceUid + "/ErrorMessage"
	}
	VeQuickItem {
		id: commandItem
		uid: tailscaleServiceUid + "/GuiCommand"
	}
	VeQuickItem {
		id: loginItem
		uid: tailscaleServiceUid + "/LoginLink"
	}
	VeQuickItem {
		id: loginItemQrCode
		uid: tailscaleServiceUid + "/LoginLinkQrCode"
	}
	VeQuickItem {
		id: stateItem
		uid: tailscaleServiceUid + "/State"
	}

	GradientListView {
		id: settingsListView

		model: ObjectModel {

			ListSwitch {
				id: switchTailscaleEnabled
				//% "Enable Tailscale"
				text: qsTrId("settings_tailscale_enable")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/Enabled"
			}

			ListLabel {
				text: root.serviceState
				allowed: root.serviceState !== ""
				horizontalAlignment: Text.AlignHCenter
			}

			Rectangle {
				id: qrCodeRect
				color: Theme.color_page_background
				width: 200
				height: qrCodeRect.visible ? (200 + Theme.geometry_listItem_content_verticalMargin) : 0
				visible: root.tailscaleEnabled && root.connectState == 6 && root.loginLink !== ""
				anchors.horizontalCenter: parent.horizontalCenter

				Image {
					id: qrCodeImage
					// NOTE: wait for https://github.com/victronenergy/gui-v2/issues/1350 to be fixed, in the meantime use the provided base64 image
					source: root.loginLinkQrCode !== "" ? "data:image/png;base64," + root.loginLinkQrCode : ""

					width: 200
					height: 200
				}
			}

			ListTextField {
				//% "Hostname"
				text: qsTrId("settings_tailscale_hostname")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/Hostname"
				placeholderText: "--"
				enabled: !root.tailscaleEnabled && userHasWriteAccess
			}

			ListTextItem {
				//% "IPv4"
				text: qsTrId("settings_tailscale_ipv4")
				dataItem.uid: root.tailscaleServiceUid + "/IPv4"
				allowed: dataItem.isValid && dataItem.value !== "" && root.tailscaleConnected
			}

			ListTextItem {
				//% "IPv6"
				text: qsTrId("settings_tailscale_ipv6")
				dataItem.uid: root.tailscaleServiceUid + "/IPv6"
				allowed: dataItem.isValid && dataItem.value !== "" && root.tailscaleConnected
			}

			ListButton {
				//% "Logout from Tailscale account"
				text: qsTrId("settings_tailscale_logout")
				//% "Log out now"
				button.text: qsTrId("settings_tailscale_logout_button")
				showAccessLevel: VenusOS.User_AccessType_Installer
				allowed: defaultAllowed && root.tailscaleConnected
				onClicked: commandItem.setValue ('logout')
			}

			ListNavigationItem {
				//% "Advanced"
				text: qsTrId("settings_tailscale_advanced")
				onClicked: {
					Global.pageManager.pushPage(tailscaleAdvanced, {"title": text})
				}

				Component {
					id: tailscaleAdvanced

					Page {
						GradientListView {
							model: ObjectModel {

								ListTextField {
									//% "Advertise routes"
									text: qsTrId("settings_tailscale_advertise_routes")
									dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/AdvertiseRoutes"
									placeholderText: "192.168.1.0/24"
									enabled: !root.tailscaleEnabled && userHasWriteAccess
								}

								ListTextField {
									//% "Custom server URL (Headscale)"
									text: qsTrId("settings_tailscale_custom_server_url")
									dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/CustomServerUrl"
									placeholderText: "--"
									enabled: !root.tailscaleEnabled && userHasWriteAccess
								}

								ListTextField {
									//% "Custom Tailscale up arguments"
									text: qsTrId("settings_tailscale_custom_tailscale_up_arguments")
									dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/CustomArguments"
									placeholderText: "--"
									enabled: !root.tailscaleEnabled && userHasWriteAccess
								}
							}
						}
					}
				}
			}
		}
	}
}
