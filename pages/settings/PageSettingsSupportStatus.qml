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

	readonly property bool isClean: fsModifiedStateItem.value === VenusOS.ModificationChecks_FsModifiedState_Clean
		&& systemHooksStateItem.valid && !(systemHooksStateItem.value & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)
	readonly property bool isModified: fsModifiedStateItem.value === VenusOS.ModificationChecks_FsModifiedState_Modified
		|| (systemHooksStateItem.valid && (systemHooksStateItem.value & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup))
	readonly property bool isRaspberry: modelItem.valid && modelItem.value.indexOf("Raspberry") !== -1
	readonly property bool isIntegrationRunning: modbusTcpItem.value !== 0
		|| (signalKItem.valid && signalKItem.value !== 0)
		|| (nodeRedItem.valid && nodeRedItem.value !== VenusOS.NodeRed_Mode_Disabled)

	function getSupportStateText() {
		if (isModified && isIntegrationRunning) {
			//% "Check below items in red and orange"
			return qsTrId("pagesettingssupportstate_support_state_check_below_red_orange")
		} else if (isModified) {
			//% "Check below items in red"
			return qsTrId("pagesettingssupportstate_support_state_check_below_red")
		} else if (isIntegrationRunning) {
			//% "Check below items in orange"
			return qsTrId("pagesettingssupportstate_support_state_check_below_orange")
		} else if (isRaspberry) {
			//% "Unsupported GX device"
			return qsTrId("pagesettingssupportstate_support_state_unsupported_gx_device")
		} else if (isClean) {
			//% "OK"
			return qsTrId("common_words_ok")
		} else {
			// fsModifiedStateItem.value is VenusOS.ModificationChecks_FsModifiedState_Unknown, but currently ignored
			//% "OK"
			return qsTrId("common_words_ok")
		}
	}

	function getSupportStateColor() {
		if (isModified && isIntegrationRunning) {
			// "Check below items in red and orange"
			return Theme.color_red
		} else if (isModified) {
			// "Check below items in red"
			return Theme.color_red
		} else if (isIntegrationRunning) {
			// "Check below items in orange"
			return Theme.color_orange
		} else if (isRaspberry) {
			// "Unsupported GX device"
			return Theme.color_red
		} else if (isClean) {
			// "OK"
			return Theme.color_green
		} else {
			// "OK"
			return Theme.color_font_secondary
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

	function getFsModifiedStateText() {
		if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Clean) {
			//% "Clean"
			return qsTrId("pagesettingssupportstate_modifiedstate_clean")
		} else if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Modified) {
			//% "Modified"
			return qsTrId("pagesettingssupportstate_modifiedstate_modified")
		} else {
			//% "Not available on this device"
			return qsTrId("pagesettingssupportstate_modifiedstate_not_available_on_this_device")
		}
	}

	function getFsModifiedStateColor() {
		if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Clean) {
			// "Clean"
			return Theme.color_green
		} else if (fsModifiedState === VenusOS.ModificationChecks_FsModifiedState_Modified) {
			// "Modified"
			return Theme.color_red
		} else {
			// "Not available on this device"
			return Theme.color_font_secondary
		}
	}

	function getSystemHooksState() {
		if ((systemHooksState === 0)) {
			//% "Not installed"
			return qsTrId("pagesettingssupportstate_custom_startup_not_installed")
		} else if (!(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)){
			if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocalDisabled)
				&& (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocalDisabled)) {
				//% "Installed but disabled (rc.local and rcS.local)"
				return qsTrId("pagesettingssupportstate_custom_startup_installed_but_disabled_rc_local_rcS_local")
			} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocalDisabled)) {
				//% "Installed but disabled (rc.local)"
				return qsTrId("pagesettingssupportstate_custom_startup_installed_but_disabled_rc_local")
			} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocalDisabled)) {
				//% "Installed but disabled (rcS.local)"
				return qsTrId("pagesettingssupportstate_custom_startup_installed_but_disabled_rcS_local")
			} else {
				// If there is no rc.local or rcS.local, then the systemHooksState is 0 and "Not installed" is returned
				//% "Installed but disabled, enables at next boot"
				return qsTrId("pagesettingssupportstate_custom_startup_installed_but_disabled_but_enable_next_boot")
			}
		} else if (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup){
			if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocal)
				&& (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocal)) {
				//% "Installed and enabled (rc.local and rcS.local)"
				return qsTrId("pagesettingssupportstate_custom_startup_installed_and_enabled_rc_local_rcS_local")
			} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocal)) {
				//% "Installed and enabled (rc.local)"
				return qsTrId("pagesettingssupportstate_custom_startup_installed_and_enabled_rc_local")
			} else if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocal)) {
				//% "Installed and enabled (rcS.local)"
				return qsTrId("pagesettingssupportstate_custom_startup_installed_and_enabled_rcS_local")
			} else {
				//% "Installed and enabled, disables at next boot"
				return qsTrId("pagesettingssupportstate_custom_startup_installed_and_enabled_but_disable_next_boot")
			}
		} else {
			//% "Unknown: %1"
			return qsTrId("pagesettingssupportstate_custom_startup_unknown").arg(systemHooksState)
		}
	}

	function getLatestReleaseFirmwareInstalled() {
		if (firmwareStateItem.valid && firmwareStateItem.value === FirmwareUpdater.Checking) {
			//% "Checking..."
			return qsTrId("pagesettingssupportstate_firmware_checking")
		} else if (firmwareStateItem.valid && firmwareStateItem.value === FirmwareUpdater.ErrorDuringChecking && !firmwareReleaseAvailableVersionItem.valid) {
			//% "Error while checking for firmware updates"
			return qsTrId("pagesettingssupportstate_firmware_online_check_failed")
		} else if (isLatestReleaseFirmwareInstalled) {
			//% "Yes"
			return qsTrId("common_words_yes")
		} else if (firmwareReleaseAvailableVersionItem.valid) {
			//: %1 = firmware version
			//% "No, %1 is available"
			return qsTrId("pagesettingssupportstate_firmware_no_available").arg(firmwareReleaseAvailableVersionItem.value)
		} else {
			//% "Unknown"
			return qsTrId("pagesettingssupportstate_firmware_unknown")
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

			ListText {
				//% "Support status"
				text: qsTrId("pagesettingssupportstate_support_status")
				secondaryText: getSupportStateText()
				secondaryTextColor: getSupportStateColor()
			}

			ListText {
				//% "Device model"
				text: qsTrId("pagesettingssupportstate_device_model")
				secondaryText: modelItem.value || ""
				secondaryTextColor: isRaspberry ? Theme.color_red : Theme.color_green
			}

			ListText {
				// Value is missing on older devices, therefore do not use colors on that
				//% "HQ serial number"
				text: qsTrId("pagesettingssupportstate_hq_serial_number")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Device/HQSerialNumber"
				preferredVisible: dataItem.valid && dataItem.value != ""
			}

			ListText {
				//% "Data partition free space"
				text: qsTrId("pagesettingssupportstate_data_free_space")
				secondaryText: scaleBytes(dataPartitionFreeSpaceItem.value)
				secondaryTextColor: dataPartitionFreeSpaceItem.value < 1024 * 1024 * 10 ? Theme.color_red : Theme.color_green
			}

			ListText {
				//% "User SSH key present"
				text: qsTrId("pagesettingssupportstate_user_ssh_key_present")
				secondaryText: sshKeyForRootPresentItem.value === 1 ? qsTrId("common_words_yes") : qsTrId("common_words_no")
			}

			SettingsListHeader {
				//% "Modifications"
				text: qsTrId("pagesettingssupportstate_modifications")
			}

			ListText {
				//% "Custom startup scripts"
				text: qsTrId("pagesettingssupportstate_custom_startup_scripts")
				secondaryText: getSystemHooksState()
				secondaryTextColor: systemHooksState < 4 ? Theme.color_green : systemHooksState < 16 ? Theme.color_orange : Theme.color_red
			}

			ListButton {
				//% "Disable custom startup scripts"
				text: qsTrId("pagesettingssupportstate_disable_custom_startup_scripts")
				//% "Disable and reboot now"
				secondaryText: qsTrId("pagesettingssupportstate_disable_and_reboot_now")
				preferredVisible: (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)
				onClicked: Global.dialogLayer.open(confirmDisableCustomStartupDialogComponent)

				Component {
					id: confirmDisableCustomStartupDialogComponent

					ModalWarningDialog {
						//% "Disable custom startup scripts"
						title: qsTrId("pagesettingssupportstate_disable_custom_startup_scripts")
						//% "Press 'OK' to disable custom startup scripts and reboot"
						description: qsTrId("pagesettingssupportstate_disable_custom_startup_scripts_description")
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
				text: qsTrId("pagesettingssupportstate_re_enable_custom_startup_scripts")
				//% "Re-enable and reboot now"
				secondaryText: qsTrId("pagesettingssupportstate_re_enable_and_reboot_now")
				preferredVisible: !(systemHooksState & VenusOS.ModificationChecks_SystemHooksState_HookLoadedAtStartup)
					&& ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocalDisabled)
						|| (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocalDisabled))
				onClicked: Global.dialogLayer.open(confirmReenableCustomStartupDialogComponent)

				Component {
					id: confirmReenableCustomStartupDialogComponent

					ModalWarningDialog {
						//% "Re-enable custom startup scripts"
						title: qsTrId("pagesettingssupportstate_reenable_and_reboot_now")
						//% "Press 'OK' to re-enable custom startup scripts and reboot"
						description: qsTrId("pagesettingssupportstate_press_ok_to_reenable_and_reboot")
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
				text: qsTrId("pagesettingssupportstate_file_system_status")
				secondaryText: getFsModifiedStateText()
				secondaryTextColor: getFsModifiedStateColor()
			}

			SettingsListHeader {
				//% "Firmware"
				text: qsTrId("pagesettingssupportstate_firmware")
			}

			ListText {
				//% "Installed firmware version"
				text: qsTrId("pagesettingssupportstate_installed_firmware_version")
				secondaryText: FirmwareVersion.versionText(firmwareInstalledVersionItem.value, "venus")
			}

			ListFirmwareImageTypeInstalled {
				//% "Installed image type"
				text: qsTrId("pagesettingssupportstate_installed_image_type")
			}

			ListText {
				//% "Latest official firmware version installed?"
				text: qsTrId("pagesettingssupportstate_latest_official_firmware_installed")
				secondaryText: getLatestReleaseFirmwareInstalled()
				secondaryTextColor: isLatestReleaseFirmwareInstalled ? Theme.color_green : Theme.color_red
			}

			ListButton {
				//% "Update the firmware to fix the modified state"
				text: qsTrId("pagesettingssupportstate_update_firmware_to_fix_modified_state")
				button.text: {
					if (Global.firmwareUpdate.state === FirmwareUpdater.DownloadingAndInstalling) {
						if (firmwareProgressItem.value) {
							//: Firmware update firmwareProgressItem. %1 = firmware version, %2 = current update progress
							//% "Updating %1 %2%"
							qsTrId("pagesettingssupportstate_updating_progress").arg(Global.firmwareUpdate.onlineAvailableVersion).arg(firmwareProgressItem.value)
						} else {
							//: %1 = firmware version
							//% "Updating %1..."
							qsTrId("pagesettingssupportstate_updating").arg(Global.firmwareUpdate.onlineAvailableVersion)
						}
					} else {
						//% "Press to update to"
						qsTrId("pagesettingssupportstate_press_to_update") + (firmwareReleaseAvailableVersionItem.valid ? " " + firmwareReleaseAvailableVersionItem.value : "")
					}
				}

				interactive: !Global.firmwareUpdate.busy
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: Global.dialogLayer.open(confirmUpdateDialogComponent)

				Component {
					id: confirmUpdateDialogComponent

					ModalWarningDialog {
						//% "Update the firmware to fix the modified state"
						title: qsTrId("pagesettingssupportstate_update_firmware_to_fix_modified_state")
						//% "This will download and update rootfs with the latest official firmware.<br>Internet connectivity is required.<br>Press 'OK' to continue."
						description: qsTrId("pagesettingssupportstate_update_firmware_to_fix_modified_state_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						onClosed: {
							if (result === T.Dialog.Accepted) {
								if ((systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcLocal)
									|| (systemHooksState & VenusOS.ModificationChecks_SystemHooksState_RcSLocal)) {
									// If custom startup scripts are enabled, ask the user to disable them first
									Qt.callLater(Global.dialogLayer.open, confirmRefreshDisableStartupScriptsDialog)
								} else {
									// Start the firmware re-install
									firmwareReleaseInstallItem.setValue(1)
								}
							}
						}
					}
				}

				Component {
					id: confirmRefreshDisableStartupScriptsDialog

					ModalWarningDialog {
						//% "Custom startup scripts"
						title: qsTrId("pagesettingssupportstate_custom_startup_scripts")
						//% "Disable also custom startup scripts?"
						description: qsTrId("pagesettingssupportstate_disable_also_custom_startup_scripts")
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
				text: qsTrId("pagesettingssupportstate_integrations")
			}

			ListText {
				//% "Modbus TCP Server"
				text: qsTrId("pagesettingssupportstate_modbus_tcp_server")
				secondaryText: modbusTcpItem.value ? CommonWords.enabled : CommonWords.disabled
				secondaryTextColor: modbusTcpItem.value ? Theme.color_orange : Theme.color_font_secondary

				VeQuickItem {
					id: modbusTcpItem
					uid: Global.systemSettings.serviceUid + "/Settings/Services/Modbus"
				}
			}

			ListText {
				//% "Signal K"
				text: qsTrId("pagesettingssupportstate_signal_k")
				secondaryText: signalKItem.valid && signalKItem.value ? CommonWords.enabled : CommonWords.disabled
				secondaryTextColor: signalKItem.valid && signalKItem.value ? Theme.color_orange : Theme.color_font_secondary
				preferredVisible: signalKItem.valid

				VeQuickItem {
					id: signalKItem
					uid: Global.venusPlatform.serviceUid + "/Services/SignalK/Enabled"
				}
			}

			ListText {
				//% "Node-RED"
				text: qsTrId("pagesettingssupportstate_node_red")
				secondaryText: nodeRedItem.valid && nodeRedItem.value === VenusOS.NodeRed_Mode_Disabled
					? CommonWords.disabled : nodeRedItem.value === VenusOS.NodeRed_Mode_Enabled
						//% "Enabled (safe mode)"
						? CommonWords.enabled : qsTrId("settings_large_enabled_safe_mode")
				secondaryTextColor: nodeRedItem.valid && nodeRedItem.value !== VenusOS.NodeRed_Mode_Disabled ? Theme.color_orange : Theme.color_font_secondary
				preferredVisible: nodeRedItem.valid

				VeQuickItem {
					id: nodeRedItem
					uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
				}
			}

			PrimaryListLabel {
				//% "Items colored orange are supported and provided by Victron Energy, but using them incorrectly can affect system stability. In case of troubleshooting, disable those first."
				text: qsTrId("pagesettingssupportstate_orange_items_description")
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
