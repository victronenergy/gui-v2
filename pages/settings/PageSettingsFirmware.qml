/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {

			ListText {
				id: remotePort

				text: CommonWords.firmware_version
				secondaryText: FirmwareVersion.versionText(dataItem.value, "venus")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Version"
			}

			ListText {
				//% "Build date/time"
				text: qsTrId("settings_build_date_time")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Build"
			}

			ListText {
				//% "Image type"
				text: qsTrId("settings_image_type")
				secondaryText: signalK.valid || nodeRed.valid ? qsTrId("settings_firmware_large") : qsTrId("settings_firmware_normal")
				preferredVisible: largeImageSupport.valid && largeImageSupport.value === 1

				VeQuickItem {
					id: signalK
					uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
				}
				VeQuickItem {
					id: nodeRed
					uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
				}
				VeQuickItem {
					id: largeImageSupport
					uid: Global.venusPlatform.serviceUid + "/Firmware/LargeImageSupport"
				}
			}

			ListNavigation {
				//% "Online updates"
				text: qsTrId("settings_online_updates")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOnline.qml", { title: text })
				}
			}

			ListNavigation {
				//% "Install firmware from SD/USB"
				text: qsTrId("settings_install_firmware_from_sd_usb")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOffline.qml", { title: text })
				}
			}

			ListNavigation {
				//% "Stored backup firmware"
				text: qsTrId("settings_stored_backup_firmware")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsRootfsSelect.qml", { title: text })
				}
			}
		}
	}
}
