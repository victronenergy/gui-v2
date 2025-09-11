/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/


import QtQuick
import Victron.VenusOS
import QtQuick.Templates as T

Page {
	id: root


	readonly property string serviceUid: (Global.venusPlatform.serviceUid + "/BackupRestore/Tank")
	readonly property string settingsUid: (Global.systemSettings.serviceUid + "/Settings/System/BackupRestore/Tank")

	function get_create_usb_button_text() {
		if (_backupRestoreAction.value === VenusOS.Tank_Backup_Restore_Action_Create_USB) {
			//% "Creating USB..."
			return qsTrId("tank_backup_creating_usb")
		} else if (_backupRestoreAction.value === VenusOS.Tank_Backup_Restore_Action_Create_USB_Successful) {
			//% "USB created successfully"
			return qsTrId("tank_backup_usb_created_successfully")
		} else if (_backupRestoreAction.value === VenusOS.Tank_Backup_Restore_Action_Create_USB_Failed) {
			//% "USB creation failed"
			return qsTrId("tank_backup_usb_creation_failed")
		} else {
			//% "Press to create USB"
			return qsTrId("tank_backup_press_to_create_usb")
		}
	}

	function get_backup_button_text() {
		if (_backupRestoreAction.value === VenusOS.Tank_Backup_Restore_Action_Backup) {
			//% "Backing up..."
			return qsTrId("tank_backup_backing_up")
		} else if (_backupRestoreAction.value === VenusOS.Tank_Backup_Restore_Action_Backup_Successful) {
			//% "Backup successful"
			return qsTrId("tank_backup_successful")
		} else if (_backupRestoreAction.value === VenusOS.Tank_Backup_Restore_Action_Backup_Failed) {
			//% "Backup failed"
			return qsTrId("tank_backup_failed")
		} else {
			//% "Press to backup"
			return qsTrId("tank_backup_press_to_backup")
		}
	}

	function get_restore_button_text() {
		if (_backupRestoreAction.value === VenusOS.Tank_Backup_Restore_Action_Restore) {
			//% "Restoring..."
			return qsTrId("tank_restore_restoring")
		} else if (_backupRestoreAction.value === VenusOS.Tank_Backup_Restore_Action_Restore_Successful) {
			//% "Restore successful"
			return qsTrId("tank_restore_successful")
		} else if (_backupRestoreAction.value === VenusOS.Tank_Backup_Restore_Action_Restore_Failed) {
			//% "Restore failed"
			return qsTrId("tank_restore_failed")
		} else {
			//% "Press to restore"
			return qsTrId("tank_restore_press_to_restore")
		}
	}

	function get_delete_button_text() {
		if (_backupRestoreAction.value === VenusOS.Tank_Backup_Restore_Action_Delete) {
			//% "Deleting..."
			return qsTrId("tank_delete_deleting")
		} else if (_backupRestoreAction.value === VenusOS.Tank_Backup_Restore_Action_Delete_Successful) {
			//% "Delete successful"
			return qsTrId("tank_delete_successful")
		} else if (_backupRestoreAction.value === VenusOS.Tank_Backup_Restore_Action_Delete_Failed) {
			//% "Delete failed"
			return qsTrId("tank_delete_failed")
		} else {
			//% "Press to delete"
			return qsTrId("tank_delete_press_to_delete")
		}
	}

	function get_tank_backup_notification(notification) {
		switch (notification)  {
			case VenusOS.Tank_Backup_Restore_Notification_Create_USB_Successful:
				//% "Create USB successful"
				return qsTrId("tank_backup_result_create_usb_successful")
			case VenusOS.Tank_Backup_Restore_Notification_Backup_Successful:
				//% "Tank settings backup successful"
				return qsTrId("tank_backup_result_backup_successful")
			case VenusOS.Tank_Backup_Restore_Notification_Restore_Successful:
				//% "Tank settings restored successful"
				return qsTrId("tank_backup_result_restore_successful")
			case VenusOS.Tank_Backup_Restore_Notification_Delete_Successful:
				//% "Tank settings backup deleted successful"
				return qsTrId("tank_backup_result_file delete_successful")
			case VenusOS.Tank_Backup_Restore_Notification_Create_USB_Failed:
				//% "Create USB failed"
				return qsTrId("tank_backup_result_create_usb_failed")
			case VenusOS.Tank_Backup_Restore_Notification_Backup_Failed:
				//% "Backup process unexpectedly closed"
				return qsTrId("tank_backup_result_backup_process_unexpedly_closed")
			case VenusOS.Tank_Backup_Restore_Notification_Restore_Failed:
				//% "Restore process unexpectedly closed"
				return qsTrId("tank_backup_result_restore_process_unexpedly_closed")
			case VenusOS.Tank_Backup_Restore_Notification_Delete_Failed:
				//% "Tank settings backup delete failed"
				return qsTrId("tank_backup_result_file_delete_failed")
			default:
				//% "Unknown"
				return qsTrId("Unknown")
		}
	}

	VeQuickItem {
		id: _backupRestoreAction
		uid: serviceUid + "/Action"
	}
	VeQuickItem {
		id: _backupRestoreError
		uid: serviceUid + "/Error"
		onValueChanged: {
			if (valid && value !== 0) {
				let errorMessage = ""
				switch (value) {
					case VenusOS.Tank_Backup_Restore_Error_UsbDriveNotMounted:
						//% "No USB drive is mounted. Please insert a USB drive and try again."
						errorMessage = qsTrId("tank_backup_error_no_usb_drive_mounted")
						break

					case VenusOS.Tank_Backup_Restore_Error_CreateUsbException:
						//% "An error occurred while creating the USB drive. Please try again."
						errorMessage = qsTrId("tank_backup_error_create_usb_exception")
						break

					case VenusOS.Tank_Backup_Restore_Error_BackupException:
						//% "An error occurred while backing up the tank settings. Please try again."
						errorMessage = qsTrId("tank_backup_error_backup_exception")
						break

					case VenusOS.Tank_Backup_Restore_Error_RestoreException:
						//% "An error occurred while restoring the tank settings. Please try again."
						errorMessage = qsTrId("tank_backup_error_restore_exception")
						break

					case VenusOS.Tank_Backup_Restore_Error_ArchiveFileDeleteFailed:
						//% "Failed to delete existing archive file on USB drive. Please try again."
						errorMessage = qsTrId("tank_backup_error_archive_file_delete_failed")
						break

					case VenusOS.Tank_Backup_Restore_Error_BackupFileDeleteFailed:
						//% "Failed to delete existing backup file on USB drive. Please try again."
						errorMessage = qsTrId("tank_backup_error_backup_file_delete_failed")
						break

					case VenusOS.Tank_Backup_Restore_Error_BackupFileMissing:
						//% "No tank settings backup file found on USB drive. Please create a backup first."
						errorMessage = qsTrId("tank_backup_error_no_backup_file_found")
						break

					default:
						//% "An unknown error occurred: #%1"
						errorMessage = qsTrId("tank_backup_error_unknown_error").arg(value)
				}
				Global.showToastNotification(VenusOS.Notification_Warning, errorMessage, 10000)
				_backupRestoreError.setValue(0) // Prevent from showing again when page re-opens
			}

		}
	}
	VeQuickItem {
		id: _backupRestoreInfo
		uid: serviceUid + "/Info"
	}
	VeQuickItem {
		id: _backupRestoreNotify
		uid: serviceUid + "/Notify"
		onValueChanged: {
			if (valid && value !== 0) {
				if (value >= 100) {
					Global.showToastNotification(VenusOS.Notification_Warning, get_tank_backup_notification(value), 10000)
				} else {
					Global.showToastNotification(VenusOS.Notification_Info, get_tank_backup_notification(value), 10000)
				}
				_backupRestoreNotify.setValue(0) // Prevent from showing again when page re-opens
			}
		}
	}

	GradientListView {
		model: ObjectModel {

			/*
			// TODO: Do not display, if all veBusDeviceRepeaters are invisible
			SettingsListHeader {
				//% "VE.Bus Settings"
				text: qsTrId("pagesettingscopysettings_vebus_settings")
				preferredVisible: veBusVisibleCount > 0
			}

			// List all VE.Bus devices, and navigate to their backup & restore page on click
			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: Global.inverterChargers.veBusDevices.count > 0

				Repeater {
					model: AggregateDeviceModel {
						sourceModels: [
							Global.inverterChargers.veBusDevices,
							// Global.inverterChargers.acSystemDevices,
							// Global.inverterChargers.inverterDevices,
							// Global.inverterChargers.chargerDevices,
						]
					}

					delegate: ListNavigation {
						id: veBusDeviceRepeater
						text: model.device.name
						preferredVisible: mkConnection.valid

						onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusBackupRestore.qml", {
							"title": text,
							"serialVebus": mkConnection.value.split("/").pop()
						})

						VeQuickItem {
							id: mkConnection
							uid: model.device.serviceUid + "/Interfaces/Mk2/Connection"
						}
					}
				}
			}
			*/

			SettingsListHeader {
				//% "Tank Settings"
				text: qsTrId("pagesettingscopysettings_tank_settings")
			}

			/*
			PrimaryListLabel {
				//% "Note: Backup files are Venus OS firmware version specific and can only be used to restore settings on products with matching firmware versions
				text: qsTrId("tankk_backup_firmware_version_specific_message")
			}
			*/

			// IDEAS:
			// - Add option field to select USB stick, if multiple are present
			// - Add option to choose backup name as in Vebus backup
			// - Add option to select backup to restore as in Vebus backup

			/*
			ListButton {
				id: _createUsbButton
				//% "Create USB stick for automatic tank settings restore"
				text: qsTrId("pagesettingscopysettings_tank_create_usb_for_automatic_restore")
				secondaryText: get_create_usb_button_text()
				enabled: _backupRestoreAction.value === 0
				// preferredVisible: !_backupNameInput.preferredVisible
				onClicked: {
					_backupRestoreAction.setValue(VenusOS.Tank_Backup_Restore_Action_Create_USB)
				}
			}
			*/

			// backup whole tank configuration
			// after backup was successful, display modal dialog and tell the user backup is completed and media was ejected
			ListButton {
				id: _backupButton
				//% "Copy all tank settings from Venus OS to USB"
				text: qsTrId("pagesettingscopysettings_tank_settings_backup_to_usb")
				//% "No USB connected"
				secondaryText: _ejectUsbButton.mounted ? get_backup_button_text() : qsTrId("pagesettingscopysettings_no_usb_connected")
				// enabled: _backupRestoreAction.value === 0
				interactive: _backupRestoreAction.value === 0 && _ejectUsbButton.mounted
				// preferredVisible: !_backupNameInput.preferredVisible
				onClicked: {
					_backupRestoreAction.setValue(VenusOS.Tank_Backup_Restore_Action_Backup)
				}
			}

			// restore whole tank configuration
			ListButton {
				id: _restoreButton
				//% "Copy all tank settings from USB to Venus OS"
				text: qsTrId("pagesettingscopysettings_restore_from_usb")
				//% "No USB connected"
				secondaryText: _ejectUsbButton.mounted ? get_restore_button_text() : qsTrId("pagesettingscopysettings_no_usb_connected")
				// enabled: _backupRestoreAction.value === 0
				interactive: _backupRestoreAction.value === 0 && _ejectUsbButton.mounted
				// preferredVisible: !_backupNameInput.preferredVisible
				onClicked: Global.dialogLayer.open(confirmRestoreDialog)

				Component {
					id: confirmRestoreDialog

					ModalWarningDialog {
						//% "Are you sure that you want to restore the tank settings from the USB?\nThis will overwrite all current settings."
						title: qsTrId("pagesettingscopysettings_restore_from_usb_warning")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						//% "Yes"
						acceptText: qsTrId("common_words_yes")
						//% "No"
						rejectText: qsTrId("common_words_no")
						onClosed: {
							if (result === T.Dialog.Accepted) {
								_backupRestoreAction.setValue(VenusOS.Tank_Backup_Restore_Action_Restore)
							}
						}
					}
				}
			}

			// Delete existing backup, only if there is one
			ListButton {
				//% "Delete tank setting from USB"
				text: qsTrId("pagesettingscopysettings_delete_backup_from_usb")
				//% "No USB connected"
				secondaryText: _ejectUsbButton.mounted ? get_delete_button_text() : qsTrId("pagesettingscopysettings_no_usb_connected")
				// enabled: _backupRestoreAction.value === 0
				interactive: _backupRestoreAction.value === 0 && _ejectUsbButton.mounted
				// preferredVisible: !_backupNameInput.preferredVisible
				onClicked: Global.dialogLayer.open(confirmDeleteDialog)

				Component {
					id: confirmDeleteDialog

					ModalWarningDialog {
						//% "Are you sure that you want to delelte the tank settings from the USB?"
						title: qsTrId("pagesettingscopysettings_delete_backup_warning")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						//% "Yes"
						acceptText: qsTrId("common_words_yes")
						//% "No"
						rejectText: qsTrId("common_words_no")
						onClosed: {
							if (result === T.Dialog.Accepted) {
								_backupRestoreAction.setValue(VenusOS.Tank_Backup_Restore_Action_Delete)
							}
						}
					}
				}
			}

			ListMountStateButton {
				id: _ejectUsbButton
				//% "Eject USB"
				text: qsTrId("components_mount_state_eject_usb")
				interactive: _backupRestoreAction.value === 0 && _ejectUsbButton.mounted
			}

			// needed, if there is already a backup on the USB, but you don't want to restore it
			ListSwitch {
				id: _autoRestoreSwitch
				//% "Prevent automatic copy of tank settings on USB insert"
				text: qsTrId("pagesettingscopysettings_tank_settings_prevent_automatic_restore_on_usb_insert")
				//% "If enabled, tank settings will not be automatically copied from USB to Venus OS when a USB with a tank settings backup is inserted."
				caption: qsTrId("pagesettingscopysettings_tank_settings_prevent_automatic_restore_on_usb_insert_description")
				dataItem.uid: settingsUid + "/PreventAutoRestore"
			}
		}
	}
}
