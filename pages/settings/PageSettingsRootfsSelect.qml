/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property bool _autoUpdateDisabled: autoUpdate.value !== 1
	property bool _switchingEnabled: backupVersionItem.valid
	property bool _rebooting

	DataPoint {
		id: autoUpdate
		source: "com.victronenergy.settings/Settings/System/AutoUpdate"
	}
	DataPoint {
		id: currentVersionItem
		source: "com.victronenergy.platform/Firmware/Installed/Version"
	}
	DataPoint {
		id: currentBuildItem
		source: "com.victronenergy.platform/Firmware/Installed/Build"
	}
	DataPoint {
		id: backupVersionItem
		source: "com.victronenergy.platform/Firmware/Backup/AvailableVersion"
	}
	DataPoint {
		id: backupBuildItem
		source: "com.victronenergy.platform/Firmware/Backup/AvailableBuild"
	}
	DataPoint {
		id: activateBackup
		source: "com.victronenergy.platform/Firmware/Backup/Activate"
	}

	SettingsListView {
		id: settingsListView

		model: ObjectModel {
			SettingsLabel {
				//% "This option allows you to switch between the current and the previous firmware version. No internet or sdcard needed."
				text: qsTrId("settings_firmware_version_switch_option")
			}

			SettingsListButton {
				id: backupVersion

				//: %1 = backup version, %2 = backup version build number
				//% "Firmware %1 (%2)"
				text: qsTrId("settings_firmware_backup_version").arg(backupVersionItem.value).arg(backupBuildItem.value)
				button.text: root._autoUpdateDisabled
					 //% "Press to boot"
				   ? qsTrId("settings_firmware_press_to_boot")
				   : CommonWords.disabled
				enabled: true
				visible: root._switchingEnabled

				onClicked: {
					if (_autoUpdateDisabled) {
						value = ""
						root._rebooting = true
						// TODO confirm whether we need to show "icon-restart-active" instead of the normal notification icon
						//: %1 = backup version
						//% "Rebooting to %1"
						Global.dialogManager.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_firmware_rebooting_to"), 50000)
						activateBackup.setValue(1)
					} else {
						//% "Switching firmware version is not possible when auto update is set to \"Check and update\". Set auto update to \"Disabled\" or \"Check only\" to enable this option."
						Global.dialogManager.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_firmware_switching_not_possible"), 10000)
					}
				}
			}

			SettingsListTextItem {
				id: currentVersion

				//: %1 = current firmware version, %2 = current firmware build number
				//% "Firmware %1 (%2)"
				text: qsTrId("settings_firmware_current_version").arg(currentVersionItem.value).arg(currentBuildItem.value)
				//% "Running"
				secondaryText: qsTrId("settings_firmware_running")
				visible: currentVersionItem.valid && root._switchingEnabled
			}

			SettingsListTextItem {
				//% "Backup firmware not available"
				text: qsTrId("settings_firmware_backup_not_available")
				visible: !currentVersion.visible && !backupVersion.visible && !root._rebooting
			}
		}
	}
}
