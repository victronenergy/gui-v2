/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/


import QtQuick
import Victron.VenusOS
import QtQuick.Templates as T

Page {
	id: root


	readonly property string serviceUid: (Global.venusPlatform.serviceUid + "/UsbTransfer/Tank")
	readonly property string settingsUid: (Global.systemSettings.serviceUid + "/Settings/System/UsbTransfer/Tank")

	function get_export_button_text() {
		if (_usbTransferTankAction.value === VenusOS.USB_Transfer_Action_Export) {
			//% "Exporting..."
			return qsTrId("pagesettingsusbtransfer_exporting")
		} else if (_usbTransferTankAction.value === VenusOS.USB_Transfer_Action_Export_Successful) {
			//% "Export successful"
			return qsTrId("pagesettingsusbtransfer_export_successful")
		} else if (_usbTransferTankAction.value === VenusOS.USB_Transfer_Action_Create_Drive_Failed) {
			//% "Drive creation failed"
			return qsTrId("pagesettingsusbtransfer_drive_creation_failed")
		} else if (_usbTransferTankAction.value === VenusOS.USB_Transfer_Action_Export_Failed) {
			//% "Export failed"
			return qsTrId("pagesettingsusbtransfer_export_failed")
		} else {
			//% "Press to export"
			return qsTrId("pagesettingsusbtransfer_press_to_export")
		}
	}

	function get_import_button_text() {
		if (_usbTransferTankAction.value === VenusOS.USB_Transfer_Action_Import) {
			//% "Importing..."
			return qsTrId("pagesettingsusbtransfer_importing")
		} else if (_usbTransferTankAction.value === VenusOS.USB_Transfer_Action_Import_Successful) {
			//% "Import successful"
			return qsTrId("pagesettingsusbtransfer_import_successful")
		} else if (_usbTransferTankAction.value === VenusOS.USB_Transfer_Action_Import_Failed) {
			//% "Import failed"
			return qsTrId("pagesettingsusbtransfer_import_failed")
		} else {
			//% "Press to import"
			return qsTrId("pagesettingsusbtransfer_press_to_import")
		}
	}

	function get_delete_button_text() {
		if (_usbTransferTankAction.value === VenusOS.USB_Transfer_Action_Delete) {
			//% "Deleting..."
			return qsTrId("pagesettingsusbtransfer_deleting")
		} else if (_usbTransferTankAction.value === VenusOS.USB_Transfer_Action_Delete_Successful) {
			//% "Delete successful"
			return qsTrId("pagesettingsusbtransfer_delete_successful")
		} else if (_usbTransferTankAction.value === VenusOS.USB_Transfer_Action_Delete_Failed) {
			//% "Delete failed"
			return qsTrId("pagesettingsusbtransfer_delete_failed")
		} else {
			//% "Press to delete"
			return qsTrId("pagesettingsusbtransfer_press_to_delete")
		}
	}

	function get_usb_transfer_notification(notification) {
		switch (notification)  {
			case VenusOS.USB_Transfer_Notification_Create_Drive_Successful:
				//% "Create drive successful"
				return qsTrId("pagesettingsusbtransfer_create_drive_successful")
			case VenusOS.USB_Transfer_Notification_Export_Successful:
				//% "Tank setups export successful"
				return qsTrId("pagesettingsusbtransfer_tank_setups_export_successful")
			case VenusOS.USB_Transfer_Notification_Import_Successful:
				//% "Tank setups import successful"
				return qsTrId("pagesettingsusbtransfer_tank_setups_import_successful")
			case VenusOS.USB_Transfer_Notification_Delete_Successful:
				//% "Tank setups export file deleted successfully"
				return qsTrId("pagesettingsusbtransfer_tank_setups_export_file_delete_successfully")
			case VenusOS.USB_Transfer_Notification_Create_Drive_Failed:
				//% "Create drive failed"
				return qsTrId("pagesettingsusbtransfer_create_drive_failed")
			case VenusOS.USB_Transfer_Notification_Export_Failed:
				//% "Export process unexpectedly closed"
				return qsTrId("pagesettingsusbtransfer_result_export_process_unexpedly_closed")
			case VenusOS.USB_Transfer_Notification_Import_Failed:
				//% "Import process unexpectedly closed"
				return qsTrId("pagesettingsusbtransfer_result_import_process_unexpedly_closed")
			case VenusOS.USB_Transfer_Notification_Delete_Failed:
				//% "Tank setup export file delete failed"
				return qsTrId("pagesettingsusbtransfer_tank_setups_export_file_delete_failed")
			default:
				//% "Unknown"
				return qsTrId("Unknown #%1").arg(notification)
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
			return qsTrId("pagesettingsusbtransfer_no_drive_found");
		}
	}

	VeQuickItem {
		id: _usbTransferTankAction
		uid: serviceUid + "/Action"
	}
	VeQuickItem {
		id: _usbTransferTankError
		uid: serviceUid + "/Error"
		onValueChanged: {
			if (valid && value !== 0) {
				let errorMessage = ""
				switch (value) {
					case VenusOS.USB_Transfer_Error_DriveNotMounted:
						//% "No drive is mounted. Please insert a drive and try again."
						errorMessage = qsTrId("pagesettingsusbtransfer_error_no_drive_mounted")
						break

					case VenusTransfer_Error_CreateDriveException:
						//% "An error occurred while creating the drive. Please try again."
						errorMessage = qsTrId("pagesettingsusbtransfer_error_create_exception")
						break

					case VenusOS.USB_Transfer_Error_ExportException:
						//% "An error occurred while exporting the tank setups. Please try again."
						errorMessage = qsTrId("pagesettingsusbtransfer_error_export_exception")
						break

					case VenusOS.USB_Transfer_Error_ImportException:
						//% "An error occurred while importing the tank setups. Please try again."
						errorMessage = qsTrId("pagesettingsusbtransfer_error_import_exception")
						break

					case VenusOS.USB_Transfer_Error_ArchiveFileDeleteFailed:
						//% "Failed to delete existing archive file on drive. Please try again."
						errorMessage = qsTrId("pagesettingsusbtransfer_error_archive_file_delete_failed")
						break

					case VenusOS.USB_Transfer_Error_ExportFileDeleteFailed:
						//% "Failed to delete existing export file on drive. Please try again."
						errorMessage = qsTrId("pagesettingsusbtransfer_error_export_file_delete_failed")
						break

					case VenusOS.USB_Transfer_Error_ExportFileMissing:
						//% "No tank setups export file found on drive. Please create an export first."
						errorMessage = qsTrId("pagesettingsusbtransfer_error_no_export_file_found")
						break

					default:
						//% "An unknown error occurred: #%1"
						errorMessage = qsTrId("pagesettingsusbtransfer_error_unknown_error").arg(value)
				}
				Global.showToastNotification(VenusOS.Notification_Warning, errorMessage, 10000)
				_usbTransferTankError.setValue(0) // Prevent from showing again when page re-opens
			}

		}
	}
	// TODO: Unused
	VeQuickItem {
		id: _usbTransferTankInfo
		uid: serviceUid + "/Info"
	}
	VeQuickItem {
		id: _usbTransferTankNotify
		uid: serviceUid + "/Notify"
		onValueChanged: {
			if (valid && value !== 0) {
				if (value >= 100) {
					Global.showToastNotification(VenusOS.Notification_Warning, get_usb_transfer_notification(value), 10000)
				} else {
					Global.showToastNotification(VenusOS.Notification_Info, get_usb_transfer_notification(value), 10000)
				}
				_usbTransferTankNotify.setValue(0) // Prevent from showing again when page re-opens
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
				text: qsTrId("pagesettingsusbtransfer_tank_settings")
			}

			ListButton {
				//% "Export all tank setups to USB drive"
				text: qsTrId("pagesettingsusbtransfer_tank_settings_export_to_usb")
				//% "No drive found"
				secondaryText: _ejectUsbButton.mounted ? get_export_button_text() : qsTrId("pagesettingsusbtransfer_no_usb_connected")
				interactive: _usbTransferTankAction.value === 0 && _ejectUsbButton.mounted
				onClicked: _autoImportSwitch.dataItem.value === 0 ? Global.dialogLayer.open(confirmExportDialog) : _usbTransferTankAction.setValue(VenusOS.USB_Transfer_Action_Export)

				Component {
					id: confirmExportDialog

					ModalWarningDialog {
						showIcon: false
						//% "Disable automatic import?"
						title: qsTrId("pagesettingsusbtransfer_confirm_export_dialog_title")
						//% "To avoid accidentally overwriting this template configuration when reinserting a USB drive or rebooting the device, we recommend disabling automatic tank setup import on this GX device."
						description: qsTrId("pagesettingsusbtransfer_confirm_export_dialog_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						//% "Yes"
						acceptText: qsTrId("common_words_yes")
						//% "No"
						rejectText: qsTrId("common_words_no")
						onClosed: {
							if (result === T.Dialog.Accepted) {
								_autoImportSwitch.dataItem.setValue(1)
							}
							_usbTransferTankAction.setValue(VenusOS.USB_Transfer_Action_Export)
						}
					}
				}
			}

			ListButton {
				//% "Import all tank setups from USB drive"
				text: qsTrId("pagesettingsusbtransfer_import_from_usb")
				//% "No drive found"
				secondaryText: _ejectUsbButton.mounted ? get_import_button_text() : qsTrId("pagesettingsusbtransfer_no_usb_connected")
				interactive: _usbTransferTankAction.value === 0 && _ejectUsbButton.mounted
				onClicked: Global.dialogLayer.open(confirmImportDialog)

				Component {
					id: confirmImportDialog

					ModalWarningDialog {
						//% "Import tank setups from USB drive?"
						title: qsTrId("pagesettingsusbtransfer_import_from_usb_warning")
						//% "Are you sure that you want to import the tank setups from the drive?\nThis will overwrite all current setups."
						description: qsTrId("pagesettingsusbtransfer_import_from_usb_warning_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						//% "Yes"
						acceptText: qsTrId("common_words_yes")
						//% "No"
						rejectText: qsTrId("common_words_no")
						onClosed: {
							if (result === T.Dialog.Accepted) {
								_usbTransferTankAction.setValue(VenusOS.USB_Transfer_Action_Import)
							}
						}
					}
				}
			}

			ListButton {
				//% "Delete all tank setups from USB drive"
				text: qsTrId("pagesettingsusbtransfer_delete_export_from_usb")
				//% "No drive found"
				secondaryText: _ejectUsbButton.mounted ? get_delete_button_text() : qsTrId("pagesettingsusbtransfer_no_usb_connected")
				interactive: _usbTransferTankAction.value === 0 && _ejectUsbButton.mounted
				onClicked: Global.dialogLayer.open(confirmDeleteDialog)

				Component {
					id: confirmDeleteDialog

					ModalWarningDialog {
						//% "Delete tank setups from USB?"
						title: qsTrId("pagesettingsusbtransfer_delete_export_warning")
						//% "Are you sure that you want to delete the tank setups from the USB?"
						description: qsTrId("pagesettingsusbtransfer_delete_export_warning_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						//% "Yes"
						acceptText: qsTrId("common_words_yes")
						//% "No"
						rejectText: qsTrId("common_words_no")
						onClosed: {
							if (result === T.Dialog.Accepted) {
								_usbTransferTankAction.setValue(VenusOS.USB_Transfer_Action_Delete)
							}
						}
					}
				}
			}

			SettingsListHeader { }

			ListMountStateButton {
				id: _ejectUsbButton
				//% "Eject USB drive"
				text: qsTrId("pagesettingsusbtransfer_eject_usb_drive")
				secondaryText: mountStateToText(mountState.value)
				interactive: _usbTransferTankAction.value === 0 && _ejectUsbButton.mounted
			}

			ListSwitch {
				id: _autoImportSwitch
				//% "Disable automatic import"
				text: qsTrId("pagesettingsusbtransfer_disable_automatic_import")
				//% "If enabled, tank setups will not be automatically imported on this GX device."
				caption: qsTrId("pagesettingsusbtransfer_disable_automatic_import_caption")
				dataItem.uid: settingsUid + "/DisableAutoImport"
			}
		}
	}
}
