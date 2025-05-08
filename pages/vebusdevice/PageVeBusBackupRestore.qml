/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/


import QtQuick
import Victron.VenusOS

Page {
	id: root

	function get_mk2vsc_state(state) {
		switch (state) {
			//% "Init"
			case 10: return qsTrId("mk2vsc_state_init")
			//% "Query products"
			case 11: return qsTrId("mk2vsc_state_query_products")
			//% "Done"
			case 12: return qsTrId("mk2vsc_state_done")
			//% "Read setting data"
			case 21: return qsTrId("mk2vsc_state_read_setting_data")
			//% "Read assistants"
			case 22: return qsTrId("mk2vsc_state_read_assistants")
			//% "Read VE.Bus configuration"
			case 23: return qsTrId("mk2vsc_state_read_vebus_configuration")
			//% "Read grid info"
			case 24: return qsTrId("mk2vsc_state_read_grid_info")
			//% "Write settings info"
			case 30: return qsTrId("mk2vsc_state_write_settings_info")
			//% "Write Settings Data"
			case 31: return qsTrId("mk2vsc_state_write_settings_data")
			//% "Write assistants"
			case 32: return qsTrId("mk2vsc_state_write_assistants")
			//% "Write VE.Bus configuration"
			case 33: return qsTrId("mk2vsc_state_write_vebus_configuration")
			//% "Resetting VE.Bus products"
			case 40: return qsTrId("mk2vsc_state_resetting_vebus_products")
			//% "Unknown"
			default: return qsTrId("Unknown")
		}
	}

	function get_mk2vsc_error(error) {
		switch (error) {
			//% "MK2/MK3 communication error"
			case 30: return qsTrId("mk2vsc_error_mk2_mk3_comm")
			//% "Product address not reachable"
			case 31: return qsTrId("mk2vsc_error_prod_addr_unreach")
			//% "Incompatible MK2 firmware version"
			case 32: return qsTrId("mk2vsc_error_incomp_mk2_fw")
			//% "No VE.Bus product was found"
			case 33: return qsTrId("mk2vsc_error_no_vebus_prod")
			//% "Too many devices on the VE.Bus"
			case 34: return qsTrId("mk2vsc_error_too_many_devices")
			//% "Timed out"
			case 35: return qsTrId("mk2vsc_error_timed_out")
			//% "Wrong password. (Use VeConfigure to set gridcode to None)"
			case 36: return qsTrId("mk2vsc_error_wrong_pass")
			//% "Malloc error"
			case 40: return qsTrId("mk2vsc_error_malloc")
			//% "Uploaded file does not contain settings data for the connected unit"
			case 45: return qsTrId("mk2vsc_error_file_no_settings")
			//% "Uploaded file does not match model and/or installed firmware version"
			case 46: return qsTrId("mk2vsc_error_file_mismatch")
			//% "More than one unknown unit detected"
			case 47: return qsTrId("mk2vsc_error_mult_unknown_units")
			//% "Updating a single unit with another unit's settings is not possible, even if they are of the same type"
			case 48: return qsTrId("mk2vsc_error_update_single_unit")
			//% "The number of units in file does not match the number of units discovered"
			case 49: return qsTrId("mk2vsc_error_unit_count_mismatch")
			//% "File open error"
			case 50: return qsTrId("mk2vsc_error_file_open")
			//% "File write error"
			case 51: return qsTrId("mk2vsc_error_file_write")
			//% "File read error"
			case 52: return qsTrId("mk2vsc_error_file_read")
			//% "File checksum error"
			case 53: return qsTrId("mk2vsc_error_file_checksum")
			//% "File incompatible version number"
			case 54: return qsTrId("mk2vsc_error_file_ver_incompat")
			//% "File section not found"
			case 55: return qsTrId("mk2vsc_error_file_section_not_found")
			//% "File format error"
			case 56: return qsTrId("mk2vsc_error_file_format")
			//% "Product number does not match file"
			case 57: return qsTrId("mk2vsc_error_prod_num_mismatch")
			//% "File expired"
			case 58: return qsTrId("mk2vsc_error_file_expired")
			//% "Wrong file format. First open the file with VE.Bus System Configurator, then save it to a new file by closing VE.Configure"
			case 59: return qsTrId("mk2vsc_error_wrong_file_format")
			//% "VE.Bus write of assistant enable/disable setting failed"
			case 60: return qsTrId("mk2vsc_error_vebus_write_fail")
			//% "Incompatible VE.Bus system configuration. Writing system configuration failed"
			case 61: return qsTrId("mk2vsc_error_vebus_config_fail")
			//% "Cannot read settings. VE.Bus system not configured"
			case 62: return qsTrId("mk2vsc_error_read_settings_fail")
			//% "Assistants write failed"
			case 70: return qsTrId("mk2vsc_error_assist_write_fail")
			//% "Assistants read failed"
			case 71: return qsTrId("mk2vsc_error_assist_read_fail")
			//% "Grid info read failed"
			case 72: return qsTrId("mk2vsc_error_grid_info_read_fail")
			//% "OSerror, unknown application"
			case 100: return qsTrId("mk2vsc_error_os_unknown_app")
			//% "Failed to open com port(no response)"
			case 201: return qsTrId("mk2vsc_error_com_port_no_resp")
			//% "Unknown"
			default: return qsTrId("Unknown")
		}
	}

	function get_vebus_backup_notification(notification) {
		switch (notification)  {
			//% "Backup successful"
			case 1: return qsTrId("vebus_backup_result_backup_successful")
			//% "Restore successful"
			case 2: return qsTrId("vebus_backup_result_restore_successful")
			//% "File delete successful"
			case 3: return qsTrId("vebus_backup_result_file delete_successful")
			//% "Backup process unexpectedly closed"
			case 101: return qsTrId("vebus_backup_result_backup_process_unexpedly_closed")
			//% "Restore process unexpectedly closed"
			case 102: return qsTrId("vebus_backup_result_restore_process_unexpedly_closed")
			//% "File delete failed"
			case 103: return qsTrId("vebus_backup_result_file_delete_failed")
			//% "Unknown"
			default: return qsTrId("Unknown")
		}
	}

	function parse_json(value) {
		let valueList
		let baseNameList = []
		try {
			valueList = JSON.parse(value)
		} catch (e) {
			console.warn("Unable to parse JSON:", value, "exception:", e)
			return
		}
		if (valueList.length < 1) {
			return
		}
		for (let i = 0; i < valueList.length; i++) {
			let token = "-" + serialVebus
			let fullName = valueList[i]
			let lastIndex = fullName.lastIndexOf(token)
			baseNameList.push(lastIndex ? fullName.slice(0,lastIndex) : fullName)
		}
		return baseNameList
	}

	property string serialVebus
	readonly property string serviceUid: (Global.venusPlatform.serviceUid + "/Vebus/Interface/" + serialVebus)

	VeQuickItem {
		id: _backupRestoreAction
		uid: root.serviceUid + "/Action"
	}

	VeQuickItem {
		id: _backupRestoreFile
		uid: root.serviceUid + "/File"
	}

	ListModel {
		id: _availableBackupsModel
	}

	ListModel {
		// Stores incompatible backup files (files for different VE.Bus firmware versions)
		id: _incompatibleBackupsModel
	}

	ListModel {
		id: _mergedBackupsModel
	}

	function updateMergedBackupsModel() {
		// Add all available backup files, including the firmware version incompatible files
		_mergedBackupsModel.clear()

		for (let i = 0; i < _availableBackupsModel.count; i++) {
			_mergedBackupsModel.append(_availableBackupsModel.get(i))
		}
		for (let j = 0; j < _incompatibleBackupsModel.count; j++) {
			_mergedBackupsModel.append(_incompatibleBackupsModel.get(j))
		}
	}

	VeQuickItem {
		id: _availableBackups
		uid: root.serviceUid + "/AvailableBackups"
		onValueChanged: {
			_availableBackupsModel.clear()
			if ((value === undefined) || (value === "")) {
				// no backups available
				updateMergedBackupsModel()
				return
			}
			let baseNameList = parse_json(value)
			if (baseNameList == undefined || baseNameList.length == 0) {
				return
			}
			for (let baseName of baseNameList) {
				_availableBackupsModel.append({display: baseName, value: baseName})
			}
			updateMergedBackupsModel()
		}
	}

	VeQuickItem {
		id: _incompatibleBackups
		uid: root.serviceUid + "/FirmwareIncompatibleBackups"
		onValueChanged: {
			_incompatibleBackupsModel.clear()
			if ((value === undefined) || (value === "")) {
				// no backups available
				updateMergedBackupsModel()
				return
			}
			let baseNameList = parse_json(value)
			if (baseNameList == undefined || baseNameList.length == 0) {
				return
			}
			for (let baseName of baseNameList) {
				//% "Incompatible"
				_incompatibleBackupsModel.append({display: baseName + " (" + qsTrId("incompatible") + ")", value: baseName})
			}
			updateMergedBackupsModel()
		}
	}

	VeQuickItem {
		id: _backupRestoreInfo
		uid: root.serviceUid + "/Info"
	}

	VeQuickItem {
		id: _backupRestoreError
		uid: root.serviceUid + "/Error"
		onValueChanged: {
			if (valid && value !== 0) {
				Global.showToastNotification(VenusOS.Notification_Warning, get_mk2vsc_error(value), 10000)
				_backupRestoreError.setValue(0) // Prevent from showing again when page re-opens
			}

		}
	}

	VeQuickItem {
		id: _backupRestoreNotify
		uid: root.serviceUid + "/Notify"
		onValueChanged: {
			if (valid && value !== 0) {
				if (value >= 100) {
					Global.showToastNotification(VenusOS.Notification_Warning, get_vebus_backup_notification(value), 10000)
				} else {
					Global.showToastNotification(VenusOS.Notification_Info, get_vebus_backup_notification(value), 10000)
				}
				_backupRestoreNotify.setValue(0) // Prevent from showing again when page re-opens
			}
		}
	}

	function resetPageToInitialState()
	{
		_backupButton.backupFileName = ""
		_restoreButton.fileNameToRestore = ""
		_restoreButton.fileToRestore = ""
		_deleteButton.fileToDelete = ""
		_deleteButton.fileNameToDelete = ""
	}

	VeQuickItem {
		id: _actionDoneReloadPage
		uid: root.serviceUid + "/Action"
		onValueChanged: {
			if (valid) {
				if (value === 0) {
					// When done "reset" the page to initial state
					resetPageToInitialState()
				}
			}
		}
	}


	GradientListView {
		model: VisibleItemModel {
			ListTextField {
				id: _backupNameInput
				//% "Backup name"
				text: qsTrId("backup_name")
				preferredVisible: _backupRestoreAction.value != VenusOS.VeBusDevice_Backup_Restore_Action_Backup
						&& !_backupButton.backupFileName
				enabled: _backupRestoreAction.value == VenusOS.VeBusDevice_Backup_Restore_Action_None
				//% "Enter backup name"
				placeholderText: qsTrId("vebus_backup_backup_name")
				validateInput: function() {
					if (secondaryText.trim() === "") {
						//% "File name cannot be empty"
						return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("backup_name_empty"))
					} else if (!secondaryText.match(/^[\w\-\.]+$/)) {
						// check for invalid characters in the name
						// [\w\-\.]: allows word characters (a-z, A-Z, 0-9, and _), dash -, and dot .
						//% "Invalid file name. Avoid using special characters"
						return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("backup_name_invalid"))
					} else {
						return Utils.validationResult(VenusOS.InputValidation_Result_OK)
					}
				}
				saveInput: function() {
					_backupButton.backupFileName = secondaryText
					secondaryText = ""
				}
			}
			ListButton {
				id: _backupButton
				property string backupFileName
				//% "Backup"
				text: qsTrId("vebus_backup_backup") + " - " + (backupFileName || _backupRestoreFile.value || "")
				secondaryText: (
					//% "Press to backup"
					(_backupRestoreAction.value != VenusOS.VeBusDevice_Backup_Restore_Action_Backup)? qsTrId("vebus_backup_press_to_backup")
					//% "Backing up..."
					: qsTrId("vebus_backup_backing_up") + (_backupRestoreInfo.valid? " " + get_mk2vsc_state(_backupRestoreInfo.value): "")
				)
				enabled: _backupRestoreAction.value == VenusOS.VeBusDevice_Backup_Restore_Action_None
				preferredVisible: !_backupNameInput.visible
				onClicked: {
					_backupRestoreFile.setValue(backupFileName)
					_backupRestoreAction.setValue(VenusOS.VeBusDevice_Backup_Restore_Action_Backup)
					backupFileName = ""
				}
			}
			ListRadioButtonGroup {
				id: _restoreOptionsList
				//% "Restore"
				text: qsTrId("vebus_backup_restore")
				optionModel: _availableBackupsModel
				//% "Select backup file to restore"
				secondaryText: qsTrId("vebus_backup_select_backup_file_to_restore")
				updateDataOnClick: false
				popDestination: root
				preferredVisible: _backupRestoreAction.value != VenusOS.VeBusDevice_Backup_Restore_Action_Restore
						&& !_restoreButton.fileToRestore
				enabled: _backupRestoreAction.value == VenusOS.VeBusDevice_Backup_Restore_Action_None
				onOptionClicked: function(index) {
					_restoreButton.fileNameToRestore = _availableBackupsModel.get(index).display
					_restoreButton.fileToRestore = _availableBackupsModel.get(index).value
				}
			}
			ListButton {
				id: _restoreButton
				property string fileToRestore
				property string fileNameToRestore
				//% "Restore"
				text: qsTrId("vebus_backup_restore") + " - " + (fileNameToRestore || _backupRestoreFile.value || "")
				secondaryText: (
					//% "Press to restore"
					(_backupRestoreAction.value != VenusOS.VeBusDevice_Backup_Restore_Action_Restore)? (qsTrId("vebus_backup_press_to_restore"))
					//% "Restoring..."
					: qsTrId("vebus_backup_restoring") + (_backupRestoreInfo.valid? " " + get_mk2vsc_state(_backupRestoreInfo.value): "")
				)
				enabled: _backupRestoreAction.value == VenusOS.VeBusDevice_Backup_Restore_Action_None
				preferredVisible: !_restoreOptionsList.preferredVisible
				onClicked: {
					_backupRestoreFile.setValue(fileToRestore)
					_backupRestoreAction.setValue(VenusOS.VeBusDevice_Backup_Restore_Action_Restore)
					fileToRestore = ""
				}
			}
			ListRadioButtonGroup {
				id: _deleteOptionsList
				//% "Delete"
				text: qsTrId("vebus_backup_delete")
				optionModel: _mergedBackupsModel
				//% "Select backup file to delete"
				secondaryText: qsTrId("vebus_backup_select_backup_file_to_delete")
				updateDataOnClick: false
				popDestination: root
				preferredVisible: _backupRestoreAction.value != VenusOS.VeBusDevice_Backup_Restore_Action_Delete
						&& !_deleteButton.fileToDelete
				enabled: _backupRestoreAction.value == VenusOS.VeBusDevice_Backup_Restore_Action_None
				onOptionClicked: function(index) {
					_deleteButton.fileNameToDelete = _mergedBackupsModel.get(index).display
					_deleteButton.fileToDelete = _mergedBackupsModel.get(index).value
				}
			}
			ListButton {
				id: _deleteButton
				property string fileToDelete
				property string fileNameToDelete
				//% "Delete"
				text: qsTrId("vebus_backup_delete") + " - " + (fileNameToDelete || _backupRestoreFile.value || "")
				secondaryText: (
					//% "Press to delete"
					(_backupRestoreAction.value != VenusOS.VeBusDevice_Backup_Restore_Action_Delete)? (qsTrId("vebus_backup_press_to_delete"))
					//% "Deleting..."
					: qsTrId("vebus_backup_deleting") + (_backupRestoreInfo.valid? " " + get_mk2vsc_state(_backupRestoreInfo.value): "")
				)
				enabled: _backupRestoreAction.value == VenusOS.VeBusDevice_Backup_Restore_Action_None
				preferredVisible: !_deleteOptionsList.preferredVisible
				onClicked: {
					_backupRestoreFile.setValue(fileToDelete)
					_backupRestoreAction.setValue(VenusOS.VeBusDevice_Backup_Restore_Action_Delete)
					fileToDelete = ""
				}
			}
			ListButton {
				id: _cancelButton
				text: CommonWords.cancel
				//% "Press to cancel"
				secondaryText: qsTrId("vebus_backup_press_to_cancel")
				enabled: _backupRestoreAction.value == VenusOS.VeBusDevice_Backup_Restore_Action_None
				preferredVisible: _backupRestoreAction.value == VenusOS.VeBusDevice_Backup_Restore_Action_None && (!_deleteOptionsList.preferredVisible  ||
								  !_restoreOptionsList.preferredVisible || !_backupNameInput.preferredVisible)
				onClicked: {
					resetPageToInitialState()
				}
			}
			PrimaryListLabel {
				//% "Note: Backup files are VE.Bus firmware version specific and can only be used to restore settings on products with matching firmware versions"
				text: qsTrId("vebus_backup_firmware_version_specific_message")
			}
		}
	}
}
