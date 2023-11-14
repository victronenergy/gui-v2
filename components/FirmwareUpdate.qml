/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	readonly property string onlineAvailableVersion: _onlineVersion.value || ""
	readonly property string offlineAvailableVersion: _offlineVersion.value || ""
	readonly property bool busy: state > FirmwareUpdater.Idle
	readonly property var state: _stateItem.value
	property bool checkingForUpdate

	property int _updateType

	property DataPoint _stateItem: DataPoint {
		source: "com.victronenergy.platform/Firmware/State"

		onValueChanged: {
			let msg = ""
			switch (value) {
			case FirmwareUpdater.Idle:
				// If a new version is available, the online/offline version value will be set
				// shortly after the state becomes Idle. So, wait briefly to see if that version
				// is set, else this may prematurely report that there is no update available.
				if (root.checkingForUpdate) {
					_updateCheckTimer.start()
				}
				break
			case FirmwareUpdater.UpdateFileNotFound:
				root._finishUpdateCheck()
				break
			case FirmwareUpdater.ErrorDuringChecking:
				//% "Error while checking for firmware updates"
				msg = qsTrId("settings_firmware_error_during_checking_for_updates")
				break
			case FirmwareUpdater.Checking:
				break
			case FirmwareUpdater.DownloadingAndInstalling:
				if (_onlineVersion.valid) {
					//: %1 = firmware version
					//% "Downloading and installing firmware %1..."
					msg = qsTrId("settings_firmware_downloading_and_installing").arg(_onlineVersion.value)
				} else if (_offlineVersion.valid) {
					//: %1 = firmware version
					//% "Installing %1..."
					msg = qsTrId("settings_firmware_installing").arg(_offlineVersion.value)
				} else {
					//% "Installing firmware..."
					msg = qsTrId("settings_firmware_installing_firmware")
				}
				break
			case FirmwareUpdater.ErrorDuringUpdating:
				//% "Error during firmware installation"
				msg = qsTrId("settings_firmware_error_during_installation")
				break
			case FirmwareUpdater.Rebooting:
				//% "Firmware installed, rebooting."
				msg = qsTrId("settings_firmware_installed_rebooting")
				break
			}
			if (msg) {
				// TODO confirm whether we need to show "icon-firmwareupdate-active" instead of the normal notification icon
				Global.showToastNotification(VenusOS.Notification_Info, msg, 10000)
			}
		}
	}

	// online updates
	property DataPoint _onlineCheckUpdate: DataPoint {
		source: "com.victronenergy.platform/Firmware/Online/Check"
	}
	property DataPoint _onlineVersion: DataPoint {
		source: "com.victronenergy.platform/Firmware/Online/AvailableVersion"
	}
	property DataPoint _onlineInstallUpdate: DataPoint {
		source: "com.victronenergy.platform/Firmware/Online/Install"
	}

	// offline updates
	property DataPoint _offlineCheckUpdate: DataPoint {
		source: "com.victronenergy.platform/Firmware/Offline/Check"
	}
	property DataPoint _offlineVersion: DataPoint {
		source: "com.victronenergy.platform/Firmware/Offline/AvailableVersion"
	}
	property DataPoint _offlineInstallUpdate: DataPoint {
		source: "com.victronenergy.platform/Firmware/Offline/Install"
	}

	property var _updateCheckTimer: Timer {
		interval: 500
		onTriggered: _finishUpdateCheck()
	}

	function checkForUpdate(updateType) {
		_updateType = updateType
		checkingForUpdate = true
		if (updateType === VenusOS.Firmware_UpdateType_Online) {
			_onlineCheckUpdate.setValue(1)
		} else if (updateType === VenusOS.Firmware_UpdateType_Offline) {
			_offlineCheckUpdate.setValue(1)
		} else {
			console.warn("checkForUpdate(): unknown firmware update type:", updateType)
		}
	}

	function installUpdate(updateType) {
		checkingForUpdate = true
		_updateType = updateType
		if (updateType === VenusOS.Firmware_UpdateType_Online) {
			_onlineInstallUpdate.setValue(1)
		} else if (updateType === VenusOS.Firmware_UpdateType_Offline) {
			_offlineInstallUpdate.setValue(1)
		} else {
			console.warn("installUpdate(): unknown firmware update type:", updateType)
		}
	}

	function _finishUpdateCheck() {
		if (!checkingForUpdate) {
			return
		}
		let msg = ""
		checkingForUpdate = false
		if (_updateType === VenusOS.Firmware_UpdateType_Online && !_onlineVersion.valid) {
			//% "No newer version available"
			msg = qsTrId("settings_firmware_no_newer_version_available")
		} else if (_updateType === VenusOS.Firmware_UpdateType_Offline && !_offlineVersion.valid) {
			//% "No firmware found"
			msg = qsTrId("settings_firmware_no_firmware_found")
		}
		if (msg) {
			Global.showToastNotification(VenusOS.Notification_Info, msg, 10000)
		}
	}
}
