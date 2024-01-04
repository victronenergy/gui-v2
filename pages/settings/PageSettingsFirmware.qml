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

		model: ObjectModel {

			ListTextItem {
				id: remotePort

				text: CommonWords.firmware_version
				dataItem.uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Version"
			}

			ListTextItem {
				//% "Build date/time"
				text: qsTrId("settings_build_date_time")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Build"
			}

			ListNavigationItem {
				//% "Online updates"
				text: qsTrId("settings_online_updates")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOnline.qml", { title: text })
				}
			}

			ListNavigationItem {
				//% "Install firmware from SD/USB"
				text: qsTrId("settings_install_firmware_from_sd_usb")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOffline.qml", { title: text })
				}
			}

			ListNavigationItem {
				//% "Stored backup firmware"
				text: qsTrId("settings_stored_backup_firmware")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsRootfsSelect.qml", { title: text })
				}
			}
		}
	}
}
