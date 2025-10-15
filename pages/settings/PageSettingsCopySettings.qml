/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/


import QtQuick
import Victron.VenusOS
import QtQuick.Templates as T

Page {
	id: root


	readonly property string serviceUid: (Global.venusPlatform.serviceUid + "/CopySettings/Tank")
	readonly property string settingsUid: (Global.systemSettings.serviceUid + "/Settings/System/CopySettings/Tank")

	function get_create_usb_button_text() {
		if (_settingsCopyAction.value === VenusOS.Copy_Settings_Action_Create_Drive) {
			//% "Creating drive..."
			return qsTrId("pagesettingscopysettings_creating_drive")
		} else if (_settingsCopyAction.value === VenusOS.Copy_Settings_Action_Create_Drive_Successful) {
			//% "Drive creation successfully"
			return qsTrId("pagesettingscopysettings_drive_creation_successful")
		} else if (_settingsCopyAction.value === VenusOS.Copy_Settings_Action_Create_Drive_Failed) {
			//% "Drive creation failed"
			return qsTrId("pagesettingscopysettings_drive_creation_failed")
		} else {
			//% "Press to create drive"
			return qsTrId("pagesettingscopysettings_press_to_create_drive")
		}
	}

	function get_export_button_text() {
		if (_settingsCopyAction.value === VenusOS.Copy_Settings_Action_Export) {
			//% "Exporting..."
			return qsTrId("pagesettingscopysettings_exporting")
		} else if (_settingsCopyAction.value === VenusOS.Copy_Settings_Action_Export_Successful) {
			//% "Export successful"
			return qsTrId("pagesettingscopysettings_export_successful")
		} else if (_settingsCopyAction.value === VenusOS.Copy_Settings_Action_Export_Failed) {
			//% "Export failed"
			return qsTrId("pagesettingscopysettings_export_failed")
		} else {
			//% "Press to export"
			return qsTrId("pagesettingscopysettings_press_to_export")
		}
	}

	function get_import_button_text() {
		if (_settingsCopyAction.value === VenusOS.Copy_Settings_Action_Import) {
			//% "Importing..."
			return qsTrId("pagesettingscopysettings_importing")
		} else if (_settingsCopyAction.value === VenusOS.Copy_Settings_Action_Import_Successful) {
			//% "Import successful"
			return qsTrId("pagesettingscopysettings_import_successful")
		} else if (_settingsCopyAction.value === VenusOS.Copy_Settings_Action_Import_Failed) {
			//% "Import failed"
			return qsTrId("pagesettingscopysettings_import_failed")
		} else {
			//% "Press to import"
			return qsTrId("pagesettingscopysettings_press_to_import")
		}
	}

	function get_delete_button_text() {
		if (_settingsCopyAction.value === VenusOS.Copy_Settings_Action_Delete) {
			//% "Deleting..."
			return qsTrId("pagesettingscopysettings_deleting")
		} else if (_settingsCopyAction.value === VenusOS.Copy_Settings_Action_Delete_Successful) {
			//% "Delete successful"
			return qsTrId("pagesettingscopysettings_delete_successful")
		} else if (_settingsCopyAction.value === VenusOS.Copy_Settings_Action_Delete_Failed) {
			//% "Delete failed"
			return qsTrId("pagesettingscopysettings_delete_failed")
		} else {
			//% "Press to delete"
			return qsTrId("pagesettingscopysettings_press_to_delete")
		}
	}

	function get_copy_settings_notification(notification) {
		switch (notification)  {
			case VenusOS.Copy_Settings_Notification_Create_Drive_Successful:
				//% "Create drive successful"
				return qsTrId("pagesettingscopysettings_create_drive_successful")
			case VenusOS.Copy_Settings_Notification_Export_Successful:
				//% "Tank setups export successful"
				return qsTrId("pagesettingscopysettings_tank_setups_export_successful")
			case VenusOS.Copy_Settings_Notification_Import_Successful:
				//% "Tank setups import successful"
				return qsTrId("pagesettingscopysettings_tank_setups_import_successful")
			case VenusOS.Copy_Settings_Notification_Delete_Successful:
				//% "Tank setups export file deleted successful"
				return qsTrId("pagesettingscopysettings_tank_setups_export_file_delete_successful")
			case VenusOS.Copy_Settings_Notification_Create_Drive_Failed:
				//% "Create drive failed"
				return qsTrId("pagesettingscopysettings_create_drive_failed")
			case VenusOS.Copy_Settings_Notification_Export_Failed:
				//% "Export process unexpectedly closed"
				return qsTrId("pagesettingscopysettings_result_export_process_unexpedly_closed")
			case VenusOS.Copy_Settings_Notification_Import_Failed:
				//% "Import process unexpectedly closed"
				return qsTrId("pagesettingscopysettings_result_import_process_unexpedly_closed")
			case VenusOS.Copy_Settings_Notification_Delete_Failed:
				//% "Tank setup export file delete failed"
				return qsTrId("pagesettingscopysettings_tank_setups_export_file_delete_failed")
			default:
				//% "Unknown"
				return qsTrId("Unknown")
		}
	}

	function mountStateToText(s) {
		switch (s) {
		case VenusOS.Storage_Mounted:
			//% "Press to eject"
			return qsTrId("components_mount_state_press_to_eject")
		case VenusOS.Storage_UnmountRequested:
		case VenusOS.Storage_UnmountBusy:
			//% "Ejecting, please wait"
			return qsTrId("components_mount_state_ejecting")
		default:
			//% "No drive found"
			return qsTrId("pagesettingscopysettings_no_drive_found");
		}
	}

	VeQuickItem {
		id: _settingsCopyAction
		uid: serviceUid + "/Action"
	}
	VeQuickItem {
		id: _backupRestoreError
		uid: serviceUid + "/Error"
		onValueChanged: {
			if (valid && value !== 0) {
				let errorMessage = ""
				switch (value) {
					case VenusOS.Copy_Settings_Error_DriveNotMounted:
						//% "No drive is mounted. Please insert a drive and try again."
						errorMessage = qsTrId("pagesettingscopysettings_error_no_usb_drive_mounted")
						break

					case VenusOS.Copy_Settings_Error_CreateDriveException:
						//% "An error occurred while creating the drive. Please try again."
						errorMessage = qsTrId("pagesettingscopysettings_error_create_usb_exception")
						break

					case VenusOS.Copy_Settings_Error_ExportException:
						//% "An error occurred while exporting the tank setups. Please try again."
						errorMessage = qsTrId("pagesettingscopysettings_error_backup_exception")
						break

					case VenusOS.Copy_Settings_Error_ImportException:
						//% "An error occurred while importing the tank setups. Please try again."
						errorMessage = qsTrId("pagesettingscopysettings_error_restore_exception")
						break

					case VenusOS.Copy_Settings_Error_ArchiveFileDeleteFailed:
						//% "Failed to delete existing archive file on drive. Please try again."
						errorMessage = qsTrId("pagesettingscopysettings_error_archive_file_delete_failed")
						break

					case VenusOS.Copy_Settings_Error_ExportFileDeleteFailed:
						//% "Failed to delete existing export file on drive. Please try again."
						errorMessage = qsTrId("pagesettingscopysettings_error_backup_file_delete_failed")
						break

					case VenusOS.Copy_Settings_Error_ExportFileMissing:
						//% "No tank setups export file found on drive. Please create an export first."
						errorMessage = qsTrId("pagesettingscopysettings_error_no_backup_file_found")
						break

					default:
						//% "An unknown error occurred: #%1"
						errorMessage = qsTrId("pagesettingscopysettings_error_unknown_error").arg(value)
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
					Global.showToastNotification(VenusOS.Notification_Warning, get_copy_settings_notification(value), 10000)
				} else {
					Global.showToastNotification(VenusOS.Notification_Info, get_copy_settings_notification(value), 10000)
				}
				_backupRestoreNotify.setValue(0) // Prevent from showing again when page re-opens
			}
		}
	}

	VeQuickItem {
		id: mountState
		uid: BackendConnection.serviceUidForType("logger") + "/Storage/MountState"
	}

	GradientListView {
		model: ObjectModel {

			SettingsListHeader {
				//% "Import and export tank setups via USB drive"
				text: qsTrId("pagesettingscopysettings_tank_settings")
			}

			// IDEAS:
			// - Add option field to select USB stick, if multiple are present
			// - Add option to select export to restore as in Vebus backup

			// export whole tank setups
			// after export was successful, display modal dialog and tell the user export is completed and media was ejected
			ListButton {
				id: _exportButton
				//% "Export all tank setups to USB drive"
				text: qsTrId("pagesettingscopysettings_tank_settings_backup_to_usb")
				//% "No drive found"
				secondaryText: _ejectUsbButton.mounted ? get_export_button_text() : qsTrId("pagesettingscopysettings_no_usb_connected")
				// enabled: _settingsCopyAction.value === 0
				interactive: _settingsCopyAction.value === 0 && _ejectUsbButton.mounted
				// preferredVisible: !_backupNameInput.preferredVisible
				/*onClicked: {
					_settingsCopyAction.setValue(VenusOS.Copy_Settings_Action_Export)
				}*/
				onClicked: _autoImportSwitch.dataItem.value === 0 ? Global.dialogLayer.open(confirmExportDialog) : _settingsCopyAction.setValue(VenusOS.Copy_Settings_Action_Export)

				Component {
					id: confirmExportDialog

					ModalWarningDialog {
						// TODO: Remove warning icon
						showIcon: false
						//% "Disable automatic import?"
						title: qsTrId("pagesettingscopysettings_confirm_export_dialog_title")
						//% "To avoid accidentally overwriting this template configuration when reinserting a USB drive or rebooting the device, we recommend disabling automatic tank setup import on this GX device."
						description: qsTrId("pagesettingscopysettings_confirm_export_dialog_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						//% "Yes"
						acceptText: qsTrId("common_words_yes")
						//% "No"
						rejectText: qsTrId("common_words_no")
						onClosed: {
							if (result === T.Dialog.Accepted) {
								_autoImportSwitch.dataItem.setValue(1)
							}
							_settingsCopyAction.setValue(VenusOS.Copy_Settings_Action_Export)
						}
					}
				}
			}

			// import whole tank setup
			ListButton {
				id: _restoreButton
				//% "Import all tank setups from USB drive"
				text: qsTrId("pagesettingscopysettings_restore_from_usb")
				//% "No drive found"
				secondaryText: _ejectUsbButton.mounted ? get_import_button_text() : qsTrId("pagesettingscopysettings_no_usb_connected")
				// enabled: _settingsCopyAction.value === 0
				interactive: _settingsCopyAction.value === 0 && _ejectUsbButton.mounted
				// preferredVisible: !_backupNameInput.preferredVisible
				onClicked: Global.dialogLayer.open(confirmRestoreDialog)

				Component {
					id: confirmRestoreDialog

					ModalWarningDialog {
						//% "Import tank setups from USB drive?"
						title: qsTrId("pagesettingscopysettings_restore_from_usb_warning")
						//% "Are you sure that you want to import the tank setups from the drive?\nThis will overwrite all current setups."
						description: qsTrId("pagesettingscopysettings_restore_from_usb_warning_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						//% "Yes"
						acceptText: qsTrId("common_words_yes")
						//% "No"
						rejectText: qsTrId("common_words_no")
						onClosed: {
							if (result === T.Dialog.Accepted) {
								_settingsCopyAction.setValue(VenusOS.Copy_Settings_Action_Import)
							}
						}
					}
				}
			}

			// Delete existing backup, only if there is one
			ListButton {
				//% "Delete all tank setups from USB drive"
				text: qsTrId("pagesettingscopysettings_delete_backup_from_usb")
				//% "No drive found"
				secondaryText: _ejectUsbButton.mounted ? get_delete_button_text() : qsTrId("pagesettingscopysettings_no_usb_connected")
				// enabled: _settingsCopyAction.value === 0
				interactive: _settingsCopyAction.value === 0 && _ejectUsbButton.mounted
				// preferredVisible: !_backupNameInput.preferredVisible
				onClicked: Global.dialogLayer.open(confirmDeleteDialog)

				Component {
					id: confirmDeleteDialog

					ModalWarningDialog {
						//% "Delete tank setups from USB?"
						title: qsTrId("pagesettingscopysettings_delete_backup_warning")
						//% "Are you sure that you want to delete the tank setups from the USB?"
						description: qsTrId("pagesettingscopysettings_delete_backup_warning_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						//% "Yes"
						acceptText: qsTrId("common_words_yes")
						//% "No"
						rejectText: qsTrId("common_words_no")
						onClosed: {
							if (result === T.Dialog.Accepted) {
								_settingsCopyAction.setValue(VenusOS.Copy_Settings_Action_Delete)
							}
						}
					}
				}
			}

			SettingsListHeader { }

			ListMountStateButton {
				id: _ejectUsbButton
				//% "Eject USB drive"
				text: qsTrId("pagesettingscopysettings_eject_usb_drive")
				secondaryText: mountStateToText(mountState.value)
				interactive: _settingsCopyAction.value === 0 && _ejectUsbButton.mounted
			}

			// needed, if there is already an export on the USB, but you don't want to import it
			ListSwitch {
				id: _autoImportSwitch
				//% "Disable automatic import"
				text: qsTrId("pagesettingscopysettings_disable_automatic_import")
				//% "If enabled, tank setups will not be automatically imported on this GX device."
				caption: qsTrId("pagesettingscopysettings_disable_automatic_import_caption")
				dataItem.uid: settingsUid + "/DisableAutoImport"
			}
		}
	}
}
