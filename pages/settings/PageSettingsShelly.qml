/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("shelly")

	VeQuickItem {
		id: shellyServiceEnabled
		uid: Services.settings.serviceUid + "/Settings/Services/Shelly"
	}

	// Get a list of all devices on the shelly service, sorted by name.
	SortedShellyDeviceModel {
		id: sortedShellyDeviceModel
		sourceModel: ShellyDeviceModel {}
	}

	GradientListView {
		id: shellyListView

		header: SettingsColumn {
			width: parent?.width ?? 0

			ListSwitch {
				//% "Enable Shelly integration"
				text: qsTrId("settings_shelly_integration")
				dataItem.uid: Services.settings.serviceUid + "/Settings/Services/Shelly"
			}

			ListSwitch {
				//% "Automatic device discovery"
				text: qsTrId("settings_shelly_autoscan")
				dataItem.uid: root.serviceUid + "/AutoScan"
				preferredVisible: shellyServiceEnabled.value === 1
			}

			ListNavigation {
				//% "Add IP address manually"
				text: qsTrId("page_settings_shelly_add_ip_address_manually")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsShellySetIpAddresses.qml", {"title": text, bindPrefix: root.serviceUid})
				preferredVisible: shellyServiceEnabled.value === 1
			}

			ListButton {
				//% "Refresh devices"
				text: qsTrId("settings_shelly_refresh_devices")
				//% "Refresh"
				secondaryText: qsTrId("settings_shelly_refresh")
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: refreshItem.setValue(1)
				preferredVisible: shellyServiceEnabled.value === 1

				VeQuickItem {
					id: refreshItem
					uid: root.serviceUid + "/Refresh"
				}
			}

			// Shown when the list is empty, to indicate to the user.
			SettingsListHeader {
				text: CommonWords.discovered_devices
				visible: shellyServiceEnabled.value === 1 && shellyListView.count === 0
			}

			Label {
				width: parent.width
				topPadding: visible ? Theme.geometry_listItem_height : 0
				//% "No devices discovered"
				text: qsTrId("settings_shelly_no_device_discovered")
				color: Theme.color_font_secondary
				font.pixelSize: Theme.font_size_body2
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.Wrap
				visible: shellyServiceEnabled.value === 1 && shellyListView.count === 0
			}
		}
		model: shellyServiceEnabled.value === 1 ? sortedShellyDeviceModel : null
		delegate: ListItemLoader {
			id: shellyDeviceDelegate

			required property string name
			required property string uid
			required property bool reachable
			required property bool supported
			required property int enabledChannelCount

			width: parent.width
			sourceComponent: supported ? supportedComponent : unsupportedComponent

			Component {
				id: supportedComponent

				ListNavigation {
					text: shellyDeviceDelegate.name
					//% "Unreachable"
					secondaryText: !shellyDeviceDelegate.reachable ? qsTrId("settings_shelly_unreachable")
							: shellyDeviceDelegate.enabledChannelCount > 0 ? CommonWords.enabled
							: ""
					secondaryTextColor: shellyDeviceDelegate.reachable && shellyDeviceDelegate.enabledChannelCount > 0
							? Theme.color_dimGreen : Theme.color_listItem_secondaryText
					onClicked: {
						Global.pageManager.pushPage("/pages/settings/PageSettingsShellyDevice.qml", {
							deviceUid: shellyDeviceDelegate.uid,
							title: shellyDeviceDelegate.name,
						})
					}
				}
			}

			Component {
				id: unsupportedComponent

				ListText {
					text: shellyDeviceDelegate.name
				}
			}
		}
		section.property: "supported"
		section.criteria: ViewSection.FullString
		section.delegate: SettingsListHeader {
			text: section == "true" ? CommonWords.discovered_devices : CommonWords.unsupported
		}
	}
}
