/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	SettingsListView {
		id: settingsListView

		model: ObjectModel {

			SettingsListTextItem {
				id: remotePort

				//% "Firmware version"
				text: qsTrId("settings_firmware_version")
				source: "com.victronenergy.platform/Firmware/Installed/Version"
			}

			SettingsListTextItem {
				//% "Build date/time"
				text: qsTrId("settings_build_date_time")
				source: "com.victronenergy.platform/Firmware/Installed/Build"
			}

			SettingsListNavigationItem {
				//% "Online updates"
				text: qsTrId("settings_online_updates")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOnline.qml", { title: text })
				}
			}

			SettingsListNavigationItem {
				//% "Install firmware from SD/USB"
				text: qsTrId("settings_install_firmware_from_sd_usb")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsFirmwareOffline.qml", { title: text })
				}
			}

			SettingsListNavigationItem {
				//% "Stored backup firmware"
				text: qsTrId("settings_stored_backup_firmware")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsRootfsSelect.qml", { title: text })
				}
			}
		}
	}
}
