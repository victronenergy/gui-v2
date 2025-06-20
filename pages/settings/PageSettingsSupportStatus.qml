/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Templates as T

Page {
	id: root

	readonly property int fsModifiedState: fsModifiedStateItem.valid ? fsModifiedStateItem.value : -1
	readonly property int systemHooksState: systemHooksStateItem.valid ? systemHooksStateItem.value : -1
	readonly property bool isLatestReleaseFirmwareInstalled: firmwareInstalledVersionItem.valid && firmwareReleaseAvailableVersionItem.valid && firmwareInstalledVersionItem.value === firmwareReleaseAvailableVersionItem.value

	function getVictronSupportState() {
		if (modelItem.value.indexOf("Raspberry") === -1) {
			if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Unknown && !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)) {
				//% "Check details"
				return qsTrId("pagesettingsmodificationchecks_support_state_check_details")
			} else if (fsModifiedState !== VenusOS.ModificationChecks_FsModifiedState_Modified && !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)) {
				//% "Clean system"
				return qsTrId("pagesettingsmodificationchecks_support_state_clean_system")
			} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup) && fsModifiedState !== VenusOS.ModificationChecks_FsModifiedState_Modified) {
				//% "Disable custom startup scripts before contacting support"
				return qsTrId("pagesettingsmodificationchecks_support_state_custom_startup_scripts")
			} else if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Modified && !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)) {
				//% "Refresh rootfs with the latest official firmware before contacting support"
				return qsTrId("pagesettingsmodificationchecks_support_state_reinstall_firmware")
			} else {
				//% "Disable custom startup scripts and refresh rootfs with the latest official firmware before contacting support"
				return qsTrId("pagesettingsmodificationchecks_support_state_custom_startup_scripts_reinstall_firmware")
			}
		} else {
			//% "Unsupported GX device"
			return qsTrId("pagesettingsmodificationchecks_support_state_unsupported_gx_device")
		}
	}

	function getVictronSupportStateColor() {
		if (modelItem.value.indexOf("Raspberry") === -1) {
			if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Unknown && !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)) {
				// "Check details"
				return Theme.color_font_secondary
			} else if (fsModifiedState !== VenusOS.ModificationChecks_FsModifiedState_Modified && !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)) {
				// "Clean system"
				return Theme.color_green
			} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup) && fsModifiedState !== VenusOS.ModificationChecks_FsModifiedState_Modified) {
				// "Disable custom startup scripts before contacting support"
				return Theme.color_red
			} else if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Modified && !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)) {
				// "Re-install latest official firmware before contacting support"
				return Theme.color_red
			} else {
				// "Disable custom startup scripts and re-install latest official firmware before contacting support"
				return Theme.color_red
			}
		} else {
			// "Unsupported GX device"
			return Theme.color_red
		}
	}

	function scaleBytes(bytes) {
		if (bytes < 1024) {
			return bytes + " B"
		} else if (bytes < 1024 * 1024) {
			return (bytes / 1024).toFixed(1) + " KB"
		} else if (bytes < 1024 * 1024 * 1024) {
			return (bytes / 1024 / 1024).toFixed(1) + " MB"
		} else {
			return (bytes / 1024 / 1024 / 1024).toFixed(1) + " GB"
		}
	}

	function getFsModifiedState() {
		if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Clean) {
			//% "Clean"
			return qsTrId("pagesettingsmodificationchecks_clean")
		} else if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Modified) {
			//% "Modified (refresh rootfs with the latest official firmware)"
			return qsTrId("pagesettingsmodificationchecks_modified")
		} else {
			//% "Not available on this device"
			return qsTrId("pagesettingsmodificationchecks_not_available_on_this_device")
		}
	}

	function getFsModifiedStateColor() {
		if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Clean) {
			//% "Clean"
			return Theme.color_green
		} else if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Modified) {
			//% "Modified (refresh rootfs with the latest official firmware)"
			return Theme.color_red
		} else {
			//% "Not available on this device"
			return Theme.color_font_secondary
		}
	}

	function getSystemHooksState() {
		if ((systemHooksState === 0)) {
			//% "Not installed"
			return qsTrId("pagesettingsmodificationchecks_custom_startup_not_installed")
		} else if (!(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)){
			if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocalDisabled)
				&& (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocalDisabled)) {
				//% "Installed but disabled (rc.local and rcS.local)"
				return qsTrId("pagesettingsmodificationchecks_custom_startup_disabled_rc_local_rcS_local")
			} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocalDisabled)) {
				//% "Installed but disabled (rc.local)"
				return qsTrId("pagesettingsmodificationchecks_custom_startup_disabled_rc_local")
			} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocalDisabled)) {
				//% "Installed but disabled (rcS.local)"
				return qsTrId("pagesettingsmodificationchecks_custom_startup_disabled_rcS_local")
			} else {
				// If there is no rc.local or rcS.local, then the systemHooksState is 0 and "Not installed" is returned
				//% "Installed but disabled, enables at next boot"
				return qsTrId("pagesettingsmodificationchecks_custom_startup_disabled_but_enable_next_boot")
			}
		} else if (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup){
			if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocal)
				&& (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocal)) {
				//% "Installed and enabled (rc.local and rcS.local)"
				return qsTrId("pagesettingsmodificationchecks_custom_startup_enabled_rc_local_rcS_local")
			} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocal)) {
				//% "Installed and enabled (rc.local)"
				return qsTrId("pagesettingsmodificationchecks_custom_startup_enabled_rc_local")
			} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocal)) {
				//% "Installed and enabled (rcS.local)"
				return qsTrId("pagesettingsmodificationchecks_custom_startup_enabled_rcS_local")
			} else {
				//% "Installed and enabled, disables at next boot"
				return qsTrId("pagesettingsmodificationchecks_custom_startup_enabled_but_disable_next_boot")
			}
		} else {
			//% "Unknown: %1"
			return qsTrId("pagesettingsmodificationchecks_unknown").arg(systemHooksState)
		}
	}

	function getLatestReleaseFirmwareInstalled() {
		if (firmwareStateItem.valid && firmwareStateItem.value === FirmwareUpdater.Checking) {
			//% "Checking..."
			return qsTrId("pagesettingsmodificationchecks_firmware_checking")
		} else if (firmwareStateItem.valid && firmwareStateItem.value === FirmwareUpdater.ErrorDuringChecking && !firmwareReleaseAvailableVersionItem.valid) {
			//% "Error while checking for firmware updates"
			return qsTrId("pagesettingsmodificationchecks_firmware_online_check_failed")
		} else if (isLatestReleaseFirmwareInstalled) {
			//% "Yes"
			return qsTrId("common_words_yes")
		} else if (firmwareReleaseAvailableVersionItem.valid) {
			//: %1 = firmware version
			//% "No, %1 is available"
			return qsTrId("pagesettingsmodificationchecks_firmware_no_available").arg(firmwareReleaseAvailableVersionItem.value)
		} else {
			//% "Unknown"
			return qsTrId("pagesettingsmodificationchecks_firmware_unknown")
		}
	}

	VeQuickItem {
		id: modelItem
		uid: Global.venusPlatform.serviceUid + "/Device/Model"
	}
	VeQuickItem {
		id: firmwareInstalledVersionItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Installed/Version"
	}
	VeQuickItem {
		id: largeImageSupportItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/LargeImageSupport"
	}
	VeQuickItem {
		id: firmwareProgressItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Progress"
	}
	VeQuickItem {
		id: firmwareReleaseAvailableVersionItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Release/AvailableVersion"
	}
	VeQuickItem {
		id: firmwareReleaseCheckItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Release/Check"
	}
	VeQuickItem {
		id: firmwareReleaseInstallItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/Release/Install"
	}
	VeQuickItem {
		id: firmwareStateItem
		uid: Global.venusPlatform.serviceUid + "/Firmware/State"
	}
	VeQuickItem {
		id: actionItem
		uid: Global.venusPlatform.serviceUid + "/ModificationChecks/Action"
	}
	VeQuickItem {
		id: dataPartitionFreeSpaceItem
		uid: Global.venusPlatform.serviceUid + "/ModificationChecks/DataPartitionFreeSpace"
	}
	VeQuickItem {
		id: sshKeyForRootPresentItem
		uid: Global.venusPlatform.serviceUid + "/ModificationChecks/SshKeyForRootPresent"
	}
	VeQuickItem {
		id: fsModifiedStateItem
		uid: Global.venusPlatform.serviceUid + "/ModificationChecks/FsModifiedState"
	}
	VeQuickItem {
		id: systemHooksStateItem
		uid: Global.venusPlatform.serviceUid + "/ModificationChecks/SystemHooksState"
	}

	GradientListView {
		model: VisibleItemModel {

			PrimaryListLabel {
				//% "This page shows the current system state, allows you to enable or disable custom startup scripts and (re-)install the latest official firmware."
				text: qsTrId("pagesettingsmodificationchecks_description")
			}

			ListText {
				//% "Support status"
				text: qsTrId("pagesettingsmodificationchecks_victron_energy_support")
				secondaryText: getVictronSupportState()
				secondaryLabel.color: getVictronSupportStateColor()
			}

			ListText {
				//% "Device model"
				text: qsTrId("pagesettingsmodificationchecks_device_model")
				secondaryText: modelItem.value || ""
				secondaryLabel.color: modelItem.valid && modelItem.value.indexOf("Raspberry") === -1 ? Theme.color_green : Theme.color_red
			}

			ListText {
				// Value is missing on older devices, therefore do not use colors on that
				//% "HQ serial number"
				text: qsTrId("pagesettingsmodificationchecks_hq_serial_number")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Device/HQSerialNumber"
				preferredVisible: dataItem.valid && dataItem.value != ""
			}

			ListText {
				//% "Data partition free space"
				text: qsTrId("pagesettingsmodificationchecks_data_free_space")
				secondaryText: scaleBytes(dataPartitionFreeSpaceItem.value)
				secondaryLabel.color: dataPartitionFreeSpaceItem.value < 1024 * 1024 * 10 ? Theme.color_red : Theme.color_green
			}

			ListText {
				//% "User SSH key present"
				text: qsTrId("pagesettingsmodificationchecks_user_ssh_key_present")
				secondaryText: sshKeyForRootPresentItem.value === 1 ? qsTrId("common_words_yes") : qsTrId("common_words_no")
			}

			SettingsListHeader {
				//% "Modifications"
				text: qsTrId("pagesettingsmodificationchecks_modifications")
			}

			ListText {
				//% "Custom startup scripts"
				text: qsTrId("pagesettingsmodificationchecks_startup_type")
				secondaryText: getSystemHooksState()
				secondaryLabel.color: systemHooksState < 4 ? Theme.color_green : systemHooksState < 16 ? Theme.color_orange : Theme.color_red
			}

			ListButton {
				//% "Disable custom startup scripts"
				text: qsTrId("pagesettingsmodificationchecks_disable_custom_boot_scripts")
				secondaryText: "Disable and reboot now"
				preferredVisible: (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)
				onClicked: Global.dialogLayer.open(confirmDisableCustomStartupDialogComponent)

				Component {
					id: confirmDisableCustomStartupDialogComponent

					ModalWarningDialog {
						//% "Disable custom startup scripts"
						title: qsTrId("pagesettingsmodificationchecks_disable_and_reboot_now")
						//% "Press 'OK' to disable custom startup scripts and reboot"
						description: qsTrId("pagesettingsmodificationchecks_press_ok_to_disable_and_reboot")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						onClosed: {
							if (result === T.Dialog.Accepted) {
								actionItem.setValue(VenusOS.ModificationChecks_Action_SystemHooksDisable)
								Global.venusPlatform.reboot()
								Qt.callLater(Global.dialogLayer.open, rebootingDisableCustomStartupDialogComponent)
							}
						}
					}
				}

				Component {
					id: rebootingDisableCustomStartupDialogComponent

					ModalRebootingDialog { }
				}
			}

			ListButton {
				//% "Re-enable custom startup scripts"
				text: qsTrId("pagesettingsmodificationchecks_re_enable_custom_boot_scripts")
				secondaryText: "Re-enable and reboot now"
				preferredVisible: !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)
					&& ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocalDisabled)
						|| (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocalDisabled))
				onClicked: Global.dialogLayer.open(confirmReenableCustomStartupDialogComponent)

				Component {
					id: confirmReenableCustomStartupDialogComponent

					ModalWarningDialog {
						//% "Re-enable custom startup scripts"
						title: qsTrId("pagesettingsmodificationchecks_reenable_and_reboot_now")
						//% "Press 'OK' to re-enable custom startup scripts and reboot"
						description: qsTrId("pagesettingsmodificationchecks_press_ok_to_reenable_and_reboot")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						onClosed: {
							if (result === T.Dialog.Accepted) {
								actionItem.setValue(VenusOS.ModificationChecks_Action_SystemHooksEnable)
								Global.venusPlatform.reboot()
								Qt.callLater(Global.dialogLayer.open, rebootingReenableCustomStartupDialogComponent)
							}
						}
					}
				}

				Component {
					id: rebootingReenableCustomStartupDialogComponent

					ModalRebootingDialog { }
				}
			}

			ListText {
				//% "File system (rootfs) status"
				text: qsTrId("pagesettingsmodificationchecks_file_system_status")
				secondaryText: getFsModifiedState()
				secondaryLabel.color: getFsModifiedStateColor()
			}

			SettingsListHeader {
				//% "Firmware"
				text: qsTrId("pagesettingsmodificationchecks_firmware")
			}

			ListText {
				//% "Installed firmware version"
				text: qsTrId("pagesettingsmodificationchecks_installed_firmware_version")
				secondaryText: FirmwareVersion.versionText(firmwareInstalledVersionItem.value, "venus")
			}

			ListFirmwareImageTypeInstalled {
				//% "Installed image type"
				text: qsTrId("pagesettingsmodificationchecks_installed_image_type")
			}

			ListText {
				//% "Latest official firmware version installed?"
				text: qsTrId("pagesettingsmodificationchecks_latest_official_firmware_installed")
				secondaryText: getLatestReleaseFirmwareInstalled()
				secondaryLabel.color: isLatestReleaseFirmwareInstalled ? Theme.color_green : Theme.color_red
			}

			ListButton {
				//% "Refresh rootfs with the latest official firmware"
				text: qsTrId("pagesettingsmodificationchecks_firmware_reinstall")
				button.text: {
					if (Global.firmwareUpdate.state === FirmwareUpdater.DownloadingAndInstalling) {
						if (firmwareProgressItem.value) {
							//: Firmware update firmwareProgressItem. %1 = firmware version, %2 = current update progress
							//% "Installing %1 %2%"
							qsTrId("settings_firmware_online_installing_progress").arg(Global.firmwareUpdate.onlineAvailableVersion).arg(firmwareProgressItem.value)
						} else {
							//: %1 = firmware version
							//% "Installing %1..."
							qsTrId("settings_firmware_online_installing").arg(Global.firmwareUpdate.onlineAvailableVersion)
						}
					} else {
						//% "Press to install"
						qsTrId("pagesettingsmodificationchecks_press_to_install") + (firmwareReleaseAvailableVersionItem.valid ? " " + firmwareReleaseAvailableVersionItem.value : "")
					}
				}

				interactive: !Global.firmwareUpdate.busy
				writeAccessLevel: VenusOS.User_AccessType_User
				//% "System settings are preserved during refresh of rootfs"
				caption: qsTrId("pagesettingsmodificationchecks_firmware_reinstall_caption")
				onClicked: Global.dialogLayer.open(confirmReinstallDialogComponent)

				Component {
					id: confirmReinstallDialogComponent

					ModalWarningDialog {
						//% "Refresh rootfs with the latest official firmware"
						title: qsTrId("pagesettingsmodificationchecks_firmware_restore_clean_state_title")
						//% "This will download and refresh rootfs with the latest official firmware.<br>Internet connectivity is required.<br>Press 'OK' to continue."
						description: qsTrId("pagesettingsmodificationchecks_firmware_restore_clean_state_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						onClosed: {
							if (result === T.Dialog.Accepted) {
								if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocal)
									|| (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocal)) {
									// If custom startup scripts are enabled, ask the user to disable them first
									Qt.callLater(Global.dialogLayer.open, confirmDisableStartupScriptsDialog)
								} else {
									// Start the firmware re-install
									firmwareReleaseInstallItem.setValue(1)
								}
							}
						}
					}
				}

				Component {
					id: confirmDisableStartupScriptsDialog

					ModalWarningDialog {
						//% "Custom startup scripts"
						title: qsTrId("pagesettingsmodificationchecks_custom_startup_scripts")
						//% "Disable also custom startup scripts?"
						description: qsTrId("pagesettingsmodificationchecks_disable_custom_startup_scripts")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						//% "Yes"
						acceptText: qsTrId("common_words_yes")
						//% "No"
						rejectText: qsTrId("common_words_no")
						onClosed: {
							if (result === T.Dialog.Accepted) {
								actionItem.setValue(VenusOS.ModificationChecks_Action_SystemHooksDisable)
							}

							// Start the firmware re-install
							firmwareReleaseInstallItem.setValue(1)
						}
					}
				}
			}

			SettingsListHeader {
				//% "Integrations"
				text: qsTrId("pagesettingsmodificationchecks_integrations")
			}

			ListText {
				//% "Modbus-TCP"
				text: qsTrId("pagesettingsmodificationchecks_modbus_tcp")
				secondaryText: modbusTcpItem.value ? CommonWords.enabled : CommonWords.disabled
				secondaryLabel.color: modbusTcpItem.value ? Theme.color_orange : Theme.color_font_secondary

				VeQuickItem {
					id: modbusTcpItem
					uid: Global.systemSettings.serviceUid + "/Settings/Services/Modbus"
				}
			}

			ListText {
				//% "Signal K"
				text: qsTrId("pagesettingsmodificationchecks_signal_k")
				secondaryText: signalKItem.valid && signalKItem.value ? CommonWords.enabled : CommonWords.disabled
				secondaryLabel.color: signalKItem.valid && signalKItem.value ? Theme.color_orange : Theme.color_font_secondary
				preferredVisible: signalKItem.valid

				VeQuickItem {
					id: signalKItem
					uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
				}
			}

			ListText {
				//% "Node-RED"
				text: qsTrId("pagesettingsmodificationchecks_node_red")
				secondaryText: nodeRedItem.valid && nodeRedItem.value === VenusOS.NodeRed_Mode_Disabled
					? CommonWords.disabled : nodeRedItem.value === VenusOS.NodeRed_Mode_Enabled
						//% "Enabled (safe mode)"
						? CommonWords.enabled : qsTrId("settings_large_enabled_safe_mode")
				secondaryLabel.color: nodeRedItem.valid && nodeRedItem.value !== VenusOS.NodeRed_Mode_Disabled ? Theme.color_orange : Theme.color_font_secondary
				preferredVisible: nodeRedItem.valid

				VeQuickItem {
					id: nodeRedItem
					uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
				}
			}

			PrimaryListLabel {
				//% "Items colored orange are supported and provided by Victron Energy, but using them incorrectly can affect system stability. In case of troubleshooting, disable those first."
				text: qsTrId("pagesettingsmodificationchecks_orange_items_description")
				color: Theme.color_font_secondary
			}
		}
	}

	Component.onCompleted: {
		// Check for latest official firmware release
		if (firmwareReleaseCheckItem.valid && firmwareReleaseCheckItem.value === 0) {
			firmwareReleaseCheckItem.setValue(2)
		}

		// Run system integrity check when the page is opened
		actionItem.setValue(VenusOS.ModificationChecks_Action_StartCheck)
	}
}
