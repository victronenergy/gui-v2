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

			ListNavigation {
				id: onlineUpdatesItem
				//% "Online updates"
				text: qsTrId("settings_online_updates")
				onClicked: Global.pageManager.pushPage(pageSettingsFirmwareOnline)
				Component { id: pageSettingsFirmwareOnline; PageSettingsFirmwareOnline { title: onlineUpdatesItem.text } }
			}

			ListNavigation {
				id: installFirmwareFromSdUsbItem
				//% "Install firmware from SD/USB"
				text: qsTrId("settings_install_firmware_from_sd_usb")
				onClicked: Global.pageManager.pushPage(pageSettingsFirmwareOffline)
				Component { id: pageSettingsFirmwareOffline; PageSettingsFirmwareOffline { title: installFirmwareFromSdUsbItem.text } }
			}

			ListNavigation {
				id: storedBackupFirmwareItem
				//% "Stored backup firmware"
				text: qsTrId("settings_stored_backup_firmware")
				onClicked: Global.pageManager.pushPage(pageSettingsRootfsSelect)
				Component { id: pageSettingsRootfsSelect; PageSettingsRootfsSelect { title: storedBackupFirmwareItem.text } }
			}
		}
	}
}
