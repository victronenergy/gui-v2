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
			//% "Wrong password"
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
			//% "Backup process unexpedly closed"
			case 101: return qsTrId("vebus_backup_result_backup_process_unexpedly_closed")
			//% "Restore process unexpedly closed"
			case 102: return qsTrId("vebus_backup_result_restore_process_unexpedly_closed")
			//% "File delete failed"
			case 103: return qsTrId("vebus_backup_result_file_delete_failed")
			//% "Unknown"
			default: return qsTrId("Unknown")
		}
	}

	property string serialVbus
	readonly property string serviceUid: (Global.venusPlatform.serviceUid + "/Vebus/Interface/"+serialVbus)

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

		ListElement {display: ""}
		ListElement {value: ""}
	}

	function updateMergedBackupsModel() {
		// Add all available backup files, including the firmware version incompatible files
		_mergedBackupsModel.clear()
		for (var i = 0; i < _availableBackupsModel.count; i++) {
			_mergedBackupsModel.append(_availableBackupsModel.get(i))
		}
		for (var j = 0; j < _incompatibleBackupsModel.count; j++) {
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
				return
			}
			let value_list
			try {
				value_list = JSON.parse(value)
			} catch (e) {
				console.warn("Unable to parse JSON:", value, "exception:", e)
				return
			}
			if (value_list.length < 1) {
				return
			}
			for (var i = 0; i < value_list.length; i++) {
				var token = "-"+serialVbus
				var fullName = value_list[i]
				var baseName
				var lastIndex = fullName.lastIndexOf(token)
				if (lastIndex === -1) {
					baseName = fullName;
				}
				else {
					// remove connection from file name end
					baseName = fullName.slice(0,lastIndex)
				}
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
				return
			}
			let value_list
			try {
				value_list = JSON.parse(value)
			} catch (e) {
				console.warn("Unable to parse JSON:", value, "exception:", e)
				return
			}
			if (value_list.length < 1) {
				return
			}
			for (var i = 0; i < value_list.length; i++) {
				var token = "-"+serialVbus
				var fullName = value_list[i]
				var baseName
				var lastIndex = fullName.lastIndexOf(token)
				if (lastIndex === -1) {
					baseName = fullName;
				}
				else {
					// remove connection from file name end
					baseName = fullName.slice(0,lastIndex)
				}
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
			if (isValid && value !== 0){
				Global.showToastNotification(VenusOS.Notification_Warning, get_mk2vsc_error(value), 10000)
				_backupRestoreError.setValue(0) // Prevent from showing again when page re-opens
			}

		}
	}

	VeQuickItem {
		id: _backupRestoreNotify
		uid: root.serviceUid + "/Notify"
		onValueChanged: {
			if (isValid && value !== 0){
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
		//% "Backup name"
		_backupNameInput.secondaryText = ""
		_backupNameInput.placeholderText = qsTrId("backup_name")
		_backupNameInput.preferredVisible = true
		//% "Select backup file to restore"
		_restoreOptionsList.secondaryText = qsTrId("select_backup_file_to_restore")
		_restoreOptionsList.preferredVisible = true
		//% "Select backup file to delete"
		_deleteOptionsList.secondaryText = qsTrId("select_backup_file_to_delete")
		_deleteOptionsList.preferredVisible = true
	}

	VeQuickItem {
		id: _actionDoneReloadPage
		uid: root.serviceUid + "/Action"
		onValueChanged: {
			if (isValid){
				if (value === 0) {
					// When done "reset" the page to initial state
					resetPageToInitialState()
				}
			}
		}
	}


	GradientListView {
		model: ObjectModel {
			PrimaryListLabel {
				//% "Note: Backup files are VE.Bus firmware version specific and can therefore not be used to restore settings after a VE.Bus firmware update.
				text: qsTrId("vebus_backup_firmware_version_specific_message")
			}

			ListTextField {
				id: _backupNameInput
				//% "Backup name"
				text: qsTrId("backup_name")
				preferredVisible: _backupRestoreAction.value !== 1
				enabled: _backupRestoreAction.value === 0
				//% "Enter backup name"
				placeholderText: qsTrId("enter_backup_name")
				onAccepted: {
					if (secondaryText !== "") {
						// check for spaces in the name
						if (secondaryText.indexOf(" ") !== -1) {
							//% "Backup name cannot contain spaces"
							Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("backup_name_no_spaces"), 10000)
						}else{
							_backupNameInput.preferredVisible = false
						}
					}
				}
			}
			ListButton {
				id: _backupButton
				//% "Backup"
				text: qsTrId("backup") + " - " + _backupNameInput.secondaryText
				secondaryText: (
					//% "Press to backup"
					(_backupRestoreAction.value !== 1)? qsTrId("vebus_device_press_to_backup")
					//% "Backing up..."
					: qsTrId("backing_up") + (_backupRestoreInfo.isValid? " " + get_mk2vsc_state(_backupRestoreInfo.value): "")
				)
				enabled: _backupRestoreAction.value === 0
				preferredVisible: !_backupNameInput.preferredVisible
				onClicked: {
					if (_backupNameInput.secondaryText !== "") {
						_backupRestoreFile.setValue(_backupNameInput.secondaryText)
						_backupRestoreAction.setValue(1)
					}else{
						Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("enter_backup_name"), 10000)
					}
				}
			}
			ListRadioButtonGroup {
				id: _restoreOptionsList
				property string fileToRestore: ""
				//% "Restore"
				text: qsTrId("restore")
				optionModel: _availableBackupsModel
				//% "Select backup file to restore"
				secondaryText: qsTrId("select_backup_file_to_restore")
				updateDataOnClick: false
				popDestination: root
				preferredVisible: _backupRestoreAction.value !== 2
				enabled: _backupRestoreAction.value === 0
				onOptionClicked: function(index) {
					_restoreOptionsList.preferredVisible = false
					_restoreOptionsList.secondaryText = _availableBackupsModel.get(index).display
					_restoreOptionsList.fileToRestore = _availableBackupsModel.get(index).value
				}
			}
			ListButton {
				//% "Restore"
				text: qsTrId("restore") + " - " + _restoreOptionsList.secondaryText
				secondaryText: (
					//% "Press to restore"
					(_backupRestoreAction.value !== 2)? (qsTrId("vebus_device_press_to_restore"))
					//% "Restoring..."
					: qsTrId("restoring") + (_backupRestoreInfo.isValid? " " + get_mk2vsc_state(_backupRestoreInfo.value): "")
				)
				enabled: _backupRestoreAction.value === 0
				preferredVisible: !_restoreOptionsList.preferredVisible
				onClicked: {
					_backupRestoreFile.setValue(_restoreOptionsList.fileToRestore)
					_backupRestoreAction.setValue(2)
				}

			}
			ListRadioButtonGroup {
				id: _deleteOptionsList
				property string fileToDelete: ""
				//% "Delete"
				text: qsTrId("delete")
				optionModel: _mergedBackupsModel
				//% "Select backup file to delete"
				secondaryText: qsTrId("select_backup_file_to_delete")
				updateDataOnClick: false
				popDestination: root
				preferredVisible: _backupRestoreAction.value !== 3
				enabled: _backupRestoreAction.value === 0
				onOptionClicked: function(index) {
					_deleteOptionsList.preferredVisible = false
					_deleteOptionsList.secondaryText = _mergedBackupsModel.get(index).display
					_deleteOptionsList.fileToDelete = _mergedBackupsModel.get(index).value
				}
			}
			ListButton {
				//% "Delete"
				text: qsTrId("delete") + " - " + _deleteOptionsList.secondaryText
				secondaryText: (
					//% "Press to delete"
					(_backupRestoreAction.value !== 3)? (qsTrId("vebus_device_press_to_delete"))
					//% "Deleting..."
					: qsTrId("deleting") + (_backupRestoreInfo.isValid? " " + get_mk2vsc_state(_backupRestoreInfo.value): "")
				)
				enabled: _backupRestoreAction.value === 0
				preferredVisible: !_deleteOptionsList.preferredVisible
				onClicked: {
					_backupRestoreFile.setValue(_deleteOptionsList.fileToDelete)
					_backupRestoreAction.setValue(3)
					//% "Select backup file to delete"
					_deleteOptionsList.secondaryText = qsTrId("select_backup_file_to_delete")
					_deleteOptionsList.preferredVisible = true
				}
			}
			ListButton {
				id: _cancelButton
				//% "Cancel"
				text: qsTrId("cancel")
				//% "Press to cancel"
				secondaryText: qsTrId("Press_to_cancel")
				enabled: _backupRestoreAction.value === 0
				preferredVisible: _backupRestoreAction.value === 0 && (!_deleteOptionsList.preferredVisible  ||
								  !_restoreOptionsList.preferredVisible || !_backupNameInput.preferredVisible)
				onClicked: {
					resetPageToInitialState()
				}
			}
		}
	}
}
