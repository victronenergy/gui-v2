/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQml
import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: ObjectModel {

			ListTextItem {
				id: remotePort

				//% "Firmware version"
				text: qsTrId("settings_firmware_version")
				dataSource: "com.victronenergy.platform/Firmware/Installed/Version"
			}

			ListTextItem {
				//% "Build date/time"
				text: qsTrId("settings_build_date_time")
				dataSource: "com.victronenergy.platform/Firmware/Installed/Build"
			}

			ListNavigationItem {
				Component {
					id: pageSettingsFirmwareOnline

					PageSettingsFirmwareOnline { }
				}

				//% "Online updates"
				text: qsTrId("settings_online_updates")
				onClicked: {
					Global.pageManager.pushPage(pageSettingsFirmwareOnline, { title: text })
				}
			}

			ListNavigationItem {
				Component {
					id: pageSettingsFirmwareOffline

					PageSettingsFirmwareOffline { }
				}

				//% "Install firmware from SD/USB"
				text: qsTrId("settings_install_firmware_from_sd_usb")
				onClicked: {
					Global.pageManager.pushPage(pageSettingsFirmwareOffline, { title: text })
				}
			}

			ListNavigationItem {
				Component {
					id: pageSettingsRootfsSelect

					PageSettingsRootfsSelect { }
				}

				//% "Stored backup firmware"
				text: qsTrId("settings_stored_backup_firmware")
				onClicked: {
					Global.pageManager.pushPage(pageSettingsRootfsSelect, { title: text })
				}
			}
		}
	}
}
