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

			ListFirmwareImageTypeInstalled { }

			ListNavigation {
				//% "Online updates"
				text: qsTrId("settings_online_updates")
				preferredVisible: onlineCheck.valid
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOnline.qml", { title: text })
				}

				VeQuickItem {
					id: onlineCheck
					uid: Global.venusPlatform.serviceUid + "/Firmware/Online/Check"
				}
			}

			ListNavigation {
				//% "Install firmware from SD/USB"
				text: qsTrId("settings_install_firmware_from_sd_usb")
				preferredVisible: offlineCheck.valid
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOffline.qml", { title: text })
				}

				VeQuickItem {
					id: offlineCheck
					uid: Global.venusPlatform.serviceUid + "/Firmware/Offline/Check"
				}
			}

			ListNavigation {
				//% "Stored backup firmware"
				text: qsTrId("settings_stored_backup_firmware")
				preferredVisible: backupActivate.valid
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsRootfsSelect.qml", { title: text })
				}

				VeQuickItem {
					id: backupActivate
					uid: Global.venusPlatform.serviceUid + "/Firmware/Backup/Activate"
				}
			}

			ListInfoLabel {
				text: "Running in a container - update by pulling a new image and recreating the container. See your deployment's documentation for details."
				preferredVisible: !onlineCheck.valid
			}
		}
	}
}
