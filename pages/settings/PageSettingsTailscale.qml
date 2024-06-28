/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

// https://tailscale.com/kb/1241/tailscale-up

/*

Add setting
dbus -y com.victronenergy.settings /Settings AddSetting Services/Tailscale Enabled 0 i 0 1 > /dev/null
dbus -y com.victronenergy.settings /Settings AddSetting Services/Tailscale AcceptRoutes 0 i 0 1 > /dev/null
dbus -y com.victronenergy.settings /Settings AddSetting Services/Tailscale AdvertiseExitNode 0 i 0 1 > /dev/null
dbus -y com.victronenergy.settings /Settings AddSetting Services/Tailscale AdvertiseRoutes '' s 0 255 > /dev/null
dbus -y com.victronenergy.settings /Settings AddSetting Services/Tailscale ExitNode '' s 0 255 > /dev/null
dbus -y com.victronenergy.settings /Settings AddSetting Services/Tailscale Hostname '' s 0 255 > /dev/null
dbus -y com.victronenergy.settings /Settings AddSetting Services/Tailscale CustomServerUrl '' s 0 255 > /dev/null
dbus -y com.victronenergy.settings /Settings AddSetting Services/Tailscale CustomArguments '' s 0 255 > /dev/null


Remove setting
dbus -y com.victronenergy.settings /Settings RemoveSettings '%["Services/Tailscale/Enabled"]'
dbus -y com.victronenergy.settings /Settings RemoveSettings '%["Services/Tailscale/AcceptRoutes"]'
dbus -y com.victronenergy.settings /Settings RemoveSettings '%["Services/Tailscale/AdvertiseExitNode"]'
dbus -y com.victronenergy.settings /Settings RemoveSettings '%["Services/Tailscale/AdvertiseRoutes"]'
dbus -y com.victronenergy.settings /Settings RemoveSettings '%["Services/Tailscale/ExitNode"]'
dbus -y com.victronenergy.settings /Settings RemoveSettings '%["Services/Tailscale/Hostname"]'
dbus -y com.victronenergy.settings /Settings RemoveSettings '%["Services/Tailscale/CustomServerUrl"]'
dbus -y com.victronenergy.settings /Settings RemoveSettings '%["Services/Tailscale/CustomArguments"]'

*/


import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string tailscaleServiceUid: BackendConnection.serviceUidForType("tailscaleGX")

	property VeQuickItem commandItem: VeQuickItem { uid: root.tailscaleServiceUid + "/GuiCommand" }
	property VeQuickItem errorMessageItem: VeQuickItem { uid: root.tailscaleServiceUid + "/ErrorMessage" }
	property VeQuickItem ipV4Item: VeQuickItem { uid: root.tailscaleServiceUid + "/IPv4" }
	property VeQuickItem ipV6Item: VeQuickItem { uid: root.tailscaleServiceUid + "/IPv6" }
	property VeQuickItem loginItem: VeQuickItem { uid: root.tailscaleServiceUid + "/LoginLink" }
	property VeQuickItem stateItem: VeQuickItem { uid: root.tailscaleServiceUid + "/State" }

	property VeQuickItem enabledItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/Enabled" }
	property VeQuickItem hostNameItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/Hostname" }

	property int connectState: stateItem.isValid ? stateItem.value : 0
	property string errorMessage: errorMessageItem.isValid && errorMessageItem.value !== "" && isEnabled ? "\n\nERROR: " + errorMessageItem.value : ""
	property string hostName: hostNameItem.isValid ? hostNameItem.value : ""
	property string ipV4: ipV4Item.isValid ? ipV4Item.value : ""
	property string ipV6: ipV6Item.isValid ? ipV6Item.value : ""
	property string loginLink: loginItem.isValid ? loginItem.value : ""

	property bool isRunning: stateItem.isValid
	property bool isEnabled: switchTailscaleEnabled.checked
	property bool isEnabledAndRunning: isEnabled && isRunning
	property bool isConnected: connectState == 100 && isEnabledAndRunning

	/*
	Component.onCompleted: {
		console.log("UID service: " + root.tailscaleServiceUid + "/State")
		console.log("UID settings: " + Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/Enabled")
	}
	*/

	function getState ()
	{
		var returnValue;

		if ( ! isRunning )
			returnValue = "Tailscale control not running"
		else if ( ! isEnabledAndRunning )
			returnValue = "Service not enabled"
		else if ( isConnected )
			returnValue = "Connection successful"
		else if ( connectState == 0 )
			return ""
		else if ( connectState == 1 )
			returnValue = "Starting..."
		else if ( connectState == 2 || connectState == 3)
			returnValue = "Tailscale starting..."
		else if ( connectState == 4)
			returnValue = "This GX device is logged out of Tailscale"
		else if ( connectState == 5)
			returnValue = "Waiting for a response from Tailscale..."
		else if ( connectState == 6)
			returnValue = "Connect this GX device to your Tailscale account by opening this link:\n\n" + loginLink + "\n\n"
		else
			returnValue =  "Unknown state: " + connectState

		return ( qsTr ( returnValue + ( connectState != 6 ? errorMessage : "" ) ) )
	}

	GradientListView {
		id: settingsListView

		model: ObjectModel {

			ListSwitch {
				id: switchTailscaleEnabled
				text: "Enable"
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/Enabled"

				bottomContentChildren: ListLabel {
					visible: text.length > 0  // in case no translation exists?
					topPadding: 0
					bottomPadding: 0
					color: Theme.color_font_secondary
					//% ""
					// text: qsTrId("settings_tailscale_")
                    text: "Enables a secure remote access via a VPN mesh network. A free account at Tailscale is required."
				}

				writeAccessLevel: VenusOS.User_AccessType_Installer
			}

			ListItem {
				id: customListItem
				text: "Current state"

				bottomContentChildren: [
					ListLabel {
						width: Math.min(implicitWidth, customListItem.maximumContentWidth)
						topPadding: 0
						bottomPadding: 0
						color: Theme.color_font_secondary
						text: getState()
					},
					Image {
						// NOTE: To discuss, if this is OK or if it's better to use the QtQrCode library
						source: loginLink !== "" ? "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=" + encodeURIComponent(loginLink) : ""
						visible: loginLink !== "" && isEnabled && connectState == 6

						width: 200
						height: 200
						anchors.horizontalCenter: parent.horizontalCenter
					}
				]
			}

			ListTextItem {
				text: "IPv4"
				dataItem.uid: root.tailscaleServiceUid + "/IPv4"
				allowed: dataItem.isValid && dataItem.value !== "" && isConnected
			}

			ListTextItem {
				text: "IPv6"
				dataItem.uid: root.tailscaleServiceUid + "/IPv6"
				allowed: dataItem.isValid && dataItem.value !== "" && isConnected
			}

			ListButton {
				text: "Logout from Tailscale account"
				button.text: "Logout"
				onClicked: commandItem.setValue ('logout')

				allowed: isConnected
				showAccessLevel: VenusOS.User_AccessType_Installer
			}

			ListSectionHeader {
				//% ""
				//text: qsTrId("settings_tailscale_")
                // NOTE: maybe put this in a separate page to not distract unexpected users
                text: "Advanced options (can only be modified when not connected)\nFor more details see https://tailscale.com/kb/1241/tailscale-up"

				allowed: VenusOS.User_AccessType_Installer
			}

			ListSwitch {
                // --accept-routes
				text: "Accept routes"
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/AcceptRoutes"

				bottomContentChildren: ListLabel {
					visible: text.length > 0  // in case no translation exists?
					topPadding: 0
					bottomPadding: 0
					color: Theme.color_font_secondary
					//% ""
					// text: qsTrId("settings_tailscale_")
                    text: "Accept subnet routes that other nodes advertise."
				}

				enabled: ! isEnabled
				showAccessLevel: VenusOS.User_AccessType_Installer
			}

			/*
			ListSwitch {
                // --advertise-exit-node
                // NOTE: disable when Exit Node is enabled
				text: "Advertise exit node"
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/AdvertiseExitNode"

				bottomContentChildren: ListLabel {
					visible: text.length > 0  // in case no translation exists?
					topPadding: 0
					bottomPadding: 0
					color: Theme.color_font_secondary
					//% ""
					// text: qsTrId("settings_tailscale_")
                    text: "Offer to be an exit node for outbound internet traffic from the Tailscale network."
				}

				enabled: ! isEnabled
				showAccessLevel: VenusOS.User_AccessType_Installer
			}
			*/

			ListTextField {
                // --advertise-routes=<ip|subnet>
				text: "Advertise routes"
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/AdvertiseRoutes"
				placeholderText: "--"

				bottomContentChildren: ListLabel {
					visible: text.length > 0  // in case no translation exists?
					topPadding: 0
					bottomPadding: 0
					color: Theme.color_font_secondary
					//% ""
					// text: qsTrId("settings_tailscale_")
                    text: "Expose physical subnet routes to your entire Tailscale network.\n\nNOTE: If you haven't enabled \"autoApprovers\" in the Tailscale admin console, then you need to manually approve the route in the Tailscale admin console. See https://tailscale.com/kb/1019/subnets -> Enable subnet routes from the admin console"
				}

				enabled: ! isEnabled
				showAccessLevel: VenusOS.User_AccessType_Installer
			}

			/*
			ListTextField {
                // --exit-node=<ip|name>
                // --exit-node-allow-lan-access
                // NOTE: disable when Advertise Exit Node is enabled
				text: "Exit node (IP or name)"
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/ExitNode"
				placeholderText: "--"

				bottomContentChildren: ListLabel {
					visible: text.length > 0  // in case no translation exists?
					topPadding: 0
					bottomPadding: 0
					color: Theme.color_font_secondary
					//% ""
					// text: qsTrId("settings_tailscale_")
                    text: "Provide a Tailscale IP or machine name to use as an exit node."
				}

				enabled: ! isEnabled
				showAccessLevel: VenusOS.User_AccessType_Installer
			}
			*/

			ListTextField {
                // --hostname=<name>
				text: "Hostname"
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/Hostname"
				placeholderText: "--"

				enabled: ! isEnabled
				showAccessLevel: VenusOS.User_AccessType_Installer
			}

			ListTextField {
                // --login-server=<url>
				text: "Custom server URL (Headscale)"
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/CustomServerUrl"
				placeholderText: "--"

				enabled: ! isEnabled
				showAccessLevel: VenusOS.User_AccessType_Installer
			}

			ListTextField {
                // NOTE: custom arguments added to the "tailscale up" command
				text: "Custom Tailscale up arguments"
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/CustomArguments"
				placeholderText: "--"

				bottomContentChildren: ListLabel {
					visible: text.length > 0  // in case no translation exists?
					topPadding: 0
					bottomPadding: 0
					color: Theme.color_font_secondary
					//% ""
					// text: qsTrId("settings_tailscale_")
                    text: "Add custom arguments to the 'tailscale up' command."
				}

				enabled: ! isEnabled
				showAccessLevel: VenusOS.User_AccessType_Installer
			}
		}
	}
}
