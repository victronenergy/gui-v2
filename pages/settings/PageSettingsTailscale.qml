/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QZXing

Page {
	id: root

	readonly property string tailscaleServiceUid: BackendConnection.serviceUidForType("tailscale")

	readonly property int connectState: stateItem.valid ? stateItem.value : 0

	readonly property string loginLink: loginItem.valid ? loginItem.value : ""
	readonly property string serviceState: getState()

	readonly property bool tailscaleEnabled: switchTailscaleEnabled.checked
	readonly property bool tailscaleConnected: stateItem.valid && tailscaleEnabled && connectState == 100

	function _checkAndCleanup(text, pattern) {
		// Trim and lowercase the text
		let textCleaned = text.trim().toLowerCase()

		// Create a pattern for the allowed characters
		let patternValidation = new RegExp("^[" + pattern + "]*$")
		let patternCleanup = new RegExp("[^" + pattern + "]", "g")

		// Check if text matches the pattern
		if (!patternValidation.test(textCleaned)) {
			return Utils.validationResult(
				VenusOS.InputValidation_Result_Warning,
				//% "'%1' was replaced with '%2' since it contained invalid characters."
				qsTrId("settings_tailscale_replaced_invalid_characters").arg(text).arg(textCleaned),
				// Remove all diallowed characters
				textCleaned.replace(patternCleanup, "")
			)
		} else {
			return Utils.validationResult(VenusOS.InputValidation_Result_OK)
		}
	}

	function getState() {
		let returnValue

		if (!stateItem.valid) {
			// Tailscale backend service not running
			//% "Starting..."
			returnValue = qsTrId("settings_tailscale_starting")
		} else if (tailscaleConnected) {
			// Tailscale connected successfully
			returnValue = ""
		} else if (connectState == 0 || connectState == 4) {
			//% "Initializing..."
			returnValue = qsTrId("settings_tailscale_initializing")
		} else if (connectState == 1) {
			//% "Backend starting..."
			returnValue = qsTrId("settings_tailscale_backend_starting")
		} else if (connectState == 2) {
			//% "Backend stopped"
			returnValue = qsTrId("settings_tailscale_backend_stopped")
		} else if (connectState == 3) {
			//% "Connection failed"
			returnValue = qsTrId("settings_tailscale_connection_failed")
		} else if (connectState == 5) {
			//% "This GX device is logged out of Tailscale,\nplease wait or check your internet connection"
			returnValue = qsTrId("settings_tailscale_logged_out")
		} else if (connectState == 6) {
			//% "Waiting for a response from Tailscale..."
			returnValue = qsTrId("settings_tailscale_wait_for_response")
		} else if (connectState == 7) {
			//% "Connection to your Tailscale account needed, see below"
			returnValue = qsTrId("settings_tailscale_wait_for_login")
		} else if (connectState == 8) {
			//% "Please wait or check your internet connection"
			returnValue = qsTrId("settings_tailscale_check_internet_connection")
		} else {
			//: %1 = number code for the connect state
			//% "Unknown state: #%1"
			returnValue = qsTrId("settings_tailscale_unknown_state").arg(connectState)
		}

		if (tailscaleEnabled && !tailscaleConnected && connectState != 7 && errorMessageItem.valid && errorMessageItem.value !== "") {
			//% "ERROR: %1"
			returnValue += "\n" + qsTrId("settings_tailscale_error").arg(errorMessageItem.value)
		}

		return returnValue
	}

	function getLocalNetworkAccess() {
		let returnValue = []

		if (accessLocalEthernetItem.valid && accessLocalEthernetItem.value === 1) {
			//% "Ethernet"
			returnValue.push(qsTrId("settings_tailscale_ethernet"))
		}

		if (accessLocalWifiItem.valid && accessLocalWifiItem.value === 1) {
			//% "WiFi"
			returnValue.push(qsTrId("settings_tailscale_wifi"))
		}

		if (customNetworksItem.valid && customNetworksItem.value !== "") {
			//% "Custom"
			returnValue.push(qsTrId("settings_tailscale_custom"))
		}

		if (returnValue.length === 0) {
			//% "Disabled"
			returnValue.push(qsTrId("settings_tailscale_disabled"))
		}

		// join the array with a comma and space
		return returnValue.join(", ")
	}

	function showEditNotification() {
		if (tailscaleEnabled && Global.systemSettings.canAccess(VenusOS.User_AccessType_Installer)) {
			//% "Disable Tailscale to edit these settings."
			Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_tailscale_disable_to_edit"), 5000)
		}
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
		id: stateItem
		uid: tailscaleServiceUid + "/State"
	}
	VeQuickItem {
		id: accessLocalEthernetItem
		uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/AccessLocalEthernet"
	}
	VeQuickItem {
		id: accessLocalWifiItem
		uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/AccessLocalWifi"
	}
	VeQuickItem {
		id: customNetworksItem
		uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/CustomNetworks"
	}

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {

			ListSwitch {
				id: switchTailscaleEnabled
				//% "Enable Tailscale"
				text: qsTrId("settings_tailscale_enable")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/Enabled"
			}

			ListText {
				//% "State"
				text: qsTrId("settings_tailscale_state")
				secondaryText: root.serviceState
				preferredVisible: root.tailscaleEnabled && root.serviceState !== ""
			}

			ListLink {
				//% "Connect this GX device to your Tailscale account"
				text: qsTrId("settings_tailscale_connect_to_account")
				url: root.loginLink
				preferredVisible: root.tailscaleEnabled && root.connectState == 7 && root.loginLink !== ""
			}

			ListTextField {
				//% "Machine name"
				text: qsTrId("settings_tailscale_machinename")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/MachineName"
				placeholderText: "--"
				interactive: dataItem.valid && !root.tailscaleEnabled
				validateInput: function() {
					return _checkAndCleanup(textField.text, "0-9a-z-")
				}
			}

			ListText {
				//% "IPv4"
				text: qsTrId("settings_tailscale_ipv4")
				dataItem.uid: root.tailscaleServiceUid + "/IPv4"
				preferredVisible: dataItem.valid && dataItem.value !== "" && root.tailscaleConnected
			}

			ListText {
				//% "IPv6"
				text: qsTrId("settings_tailscale_ipv6")
				dataItem.uid: root.tailscaleServiceUid + "/IPv6"
				preferredVisible: dataItem.valid && dataItem.value !== "" && root.tailscaleConnected
			}

			ListButton {
				//% "Logout from Tailscale account"
				text: qsTrId("settings_tailscale_logout")
				//% "Log out now"
				secondaryText: qsTrId("settings_tailscale_logout_button")
				showAccessLevel: VenusOS.User_AccessType_Installer
				preferredVisible: root.tailscaleConnected
				onClicked: commandItem.setValue('logout')
			}

			ListNavigation {
				//% "Local network access"
				text: qsTrId("settings_tailscale_local_network_access")
				secondaryText: getLocalNetworkAccess()
				onClicked: {
					Global.pageManager.pushPage(tailscaleLocalNetworkAccess, {"title": text})
				}

				Component {
					id: tailscaleLocalNetworkAccess

					Page {
						GradientListView {
							model: VisibleItemModel {
								ListSwitch {
									//% "Access local ethernet network"
									text: qsTrId("settings_tailscale_local_network_access_ethernet")
									interactive: dataItem.valid && !root.tailscaleEnabled
									dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/AccessLocalEthernet"
								}

								ListSwitch {
									//% "Access local WiFi network"
									text: qsTrId("settings_tailscale_local_network_access_wifi")
									interactive: dataItem.valid && !root.tailscaleEnabled
									dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/AccessLocalWifi"
								}

								ListTextField {
									//% "Custom network(s)"
									text: qsTrId("settings_tailscale_local_network_access_custom_networks")
									dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/CustomNetworks"
									//% "Example: 192.168.1.0/24"
									placeholderText: qsTrId("settings_tailscale_local_network_access_custom_networks_placeholder")
									interactive: dataItem.valid && !root.tailscaleEnabled
									validateInput: function() {
										return _checkAndCleanup(textField.text, "0-9./,")
									}
								}

								PrimaryListLabel {
									//% "Explanation:\n\n"
									//% "This feature, called subnet routes by Tailscale, "
									//% "allows remote access to other devices in the local network(s).\n\n"
									//% "The custom networks field accepts a comma-separated list of CIDR notation subnets.\n\n"
									//% "After adding/enabling a new network, you need to approve it in the Tailscale admin console once."
									text: qsTrId("settings_tailscale_local_network_access_explanation")
								}
							}
						}

						Component.onCompleted: {
							showEditNotification()
						}
					}
				}
			}

			ListNavigation {
				//% "Advanced"
				text: qsTrId("settings_tailscale_advanced")
				onClicked: {
					Global.pageManager.pushPage(tailscaleAdvanced, {"title": text})
				}

				Component {
					id: tailscaleAdvanced

					Page {
						GradientListView {
							model: VisibleItemModel {
								ListTextField {
									//% "Custom \"tailscale up\" arguments"
									text: qsTrId("settings_tailscale_advanced_custom_tailscale_up_arguments")
									dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/CustomArguments"
									placeholderText: "--"
									interactive: dataItem.valid && !root.tailscaleEnabled
									validateInput: function() {
										return _checkAndCleanup(textField.text, "0-9a-z-_=+:., ")
									}
								}

								ListTextField {
									//% "Custom server URL (Headscale)"
									text: qsTrId("settings_tailscale_advanced_custom_server_url")
									dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/CustomServerUrl"
									placeholderText: "--"
									interactive: dataItem.valid && !root.tailscaleEnabled
									validateInput: function() {
										return _checkAndCleanup(textField.text, "0-9a-z-:/.")
									}
								}
							}
						}

						Component.onCompleted: {
							showEditNotification()
						}
					}
				}
			}
		}
	}
}
