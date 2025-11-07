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
		} else {
			//% "Press to export"
			return qsTrId("pagesettingsusbtransfer_press_to_export")
		}
	}

	function get_import_button_text() {
		if (_usbTransferTankAction.value === VenusOS.USB_Transfer_Action_Import) {
			//% "Importing..."
			return qsTrId("pagesettingsusbtransfer_importing")
		} else {
			//% "Press to import"
			return qsTrId("pagesettingsusbtransfer_press_to_import")
		}
	}

	function get_delete_button_text() {
		if (_usbTransferTankAction.value === VenusOS.USB_Transfer_Action_Delete) {
			//% "Deleting..."
			return qsTrId("pagesettingsusbtransfer_deleting")
		} else {
			//% "Press to delete"
			return qsTrId("pagesettingsusbtransfer_press_to_delete")
		}
	}

	function get_usb_transfer_notification(notification) {
		switch (notification)  {
			case VenusOS.USB_Transfer_Notification_ExportSuccessful:
				//% "Tank setups export successful"
				return qsTrId("pagesettingsusbtransfer_tank_setups_export_successful")
			case VenusOS.USB_Transfer_Notification_ImportSuccessful:
				//% "Tank setups import successful"
				return qsTrId("pagesettingsusbtransfer_tank_setups_import_successful")
			case VenusOS.USB_Transfer_Notification_DeleteSuccessful:
				//% "Tank setups export file deleted successfully"
				return qsTrId("pagesettingsusbtransfer_tank_setups_export_file_delete_successfully")
			case VenusOS.USB_Transfer_Notification_CreateDriveException:
				//% "An error occurred while creating the drive"
				return qsTrId("pagesettingsusbtransfer_create_drive_failed")
			case VenusOS.USB_Transfer_Notification_ExportException:
				//% "An error occurred while exporting the tank setups"
				return qsTrId("pagesettingsusbtransfer_result_export_process_unexpedly_closed")
			case VenusOS.USB_Transfer_Notification_ImportException:
				if (_usbTransferTankExitCode.valid && _usbTransferTankExitCode.value !== 0) {
					switch (_usbTransferTankExitCode.value) {
						case 100:
							//% "An error occurred while importing the tank setups: There are more enabled thanks in the import file as on this Venus OS system"
							return qsTrId("pagesettingsusbtransfer_error_import_100")
							break
						case 101:
							//% "An error occurred while importing the tank setups: The import file is corrupted"
							return qsTrId("pagesettingsusbtransfer_error_import_101")
							break
						case 102:
							//% "An error occurred while importing the tank setups: The import file format is not supported"
							return qsTrId("pagesettingsusbtransfer_error_import_102")
							break
					}
				}
				//% "An error occurred while importing the tank setups"
				return qsTrId("pagesettingsusbtransfer_result_import_process_unexpedly_closed")
			case VenusOS.USB_Transfer_Notification_DeleteException:
				//% "Tank setup export file delete failed"
				return qsTrId("pagesettingsusbtransfer_tank_setups_export_file_delete_failed")

			case VenusOS.USB_Transfer_Notification_DriveNotMountedError:
				//% "No drive is mounted. Please insert a drive and try again"
				return qsTrId("pagesettingsusbtransfer_error_no_drive_mounted")
				break

			case VenusOS.USB_Transfer_Notification_ArchiveFileDeleteFailedError:
				//% "Failed to delete existing archive file on drive"
				return qsTrId("pagesettingsusbtransfer_error_archive_file_delete_failed")
				break

			case VenusOS.USB_Transfer_Notification_ExportFileDeleteFailedError:
				//% "Failed to delete existing export file on drive"
				return qsTrId("pagesettingsusbtransfer_error_export_file_delete_failed")
				break

			case VenusOS.USB_Transfer_Notification_ExportFileMissingError:
				//% "No tank setups export file found on drive. Please create an export first"
				return qsTrId("pagesettingsusbtransfer_error_no_export_file_found")
				break
			default:
				//% "Unknown #%1"
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
		id: _usbTransferTankExitCode
		uid: serviceUid + "/ExitCode"
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
				_usbTransferTankExitCode.setValue(0) // Reset exit code after showing notification
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
						//% "Disable automatic import?"
						title: qsTrId("pagesettingsusbtransfer_confirm_export_dialog_title")
						//% "To avoid accidentally overwriting this template configuration when reinserting a USB drive or rebooting the device, we recommend disabling automatic tank setup import on this GX device."
						description: qsTrId("pagesettingsusbtransfer_confirm_export_dialog_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						icon.source: ""
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
