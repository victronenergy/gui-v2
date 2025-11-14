/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// Allows VRM instances to be changed for devices on the system.
//
// Every device has a device-class:vrm-instance pair, stored as:
// - (dbus) com.victronenergy.settings/Settings/Devices/<unique device identifier>/ClassAndVrmInstance
// - (mqtt) W/<portalId>/settings/0/Settings/Devices/<unique device identifier>/ClassAndVrmInstance
//
// VRM instances must be unique among devices with the same type (device class). If the user tries
// to use an existing instance for that type, a dialog will appear to prompt an instance swap.
// Device classes should correspond to a known service type, such as "solarcharger" or "tank".
//
// Changing a VRM instance number will cause that number to be set as the device instance on reboot;
// until then, the VRM instance can be changed freely by the user without being applied to the
// device instance, so be careful here to distinguish between VRM instances and device instances.
// Device instances can be used to locate a device based on the device class, but VRM instances
// cannot, as they may change at any time.
//
// If a VRM instance is changed, and the app is restarted without a system reboot, then that device
// will appear in this list as "Unconnected", as there is currently no easy way to identify a device
// using its VRM instance. The device instance must be used instead, but if the VRM instance has not
// been applied to the device instance, then the device will not be locatable.


Page {
	id: root

	function _changeVrmInstance(uid, deviceClass, newVrmInstance, errorFunc) {
		// See if another device of this class already has this VRM instance.
		const conflictingInstanceUid = classAndVrmInstanceModel.findInstanceUid(deviceClass, newVrmInstance)
		if (conflictingInstanceUid) {
			// Show a dialog to confirm whether to swap device instances with the conflicting one.
			const maximumVrmInstance = classAndVrmInstanceModel.maximumVrmInstance(deviceClass)
			const dialogParams = {
				instanceAUid: uid,
				instanceBUid: conflictingInstanceUid,
				temporaryVrmInstance: maximumVrmInstance < 0 ? 0 : maximumVrmInstance + 1,
				errorFunc: errorFunc,
			}
			Global.dialogLayer.open(swapDialogComponent, dialogParams)
			return false
		} else {
			// No conflicts; just set the new VRM instance.
			return classAndVrmInstanceModel.setVrmInstance(uid, newVrmInstance)
		}
	}

	// If user changes the VRM instance, ask whether reboot should be done when page is popped.
	tryPop: () => {
		// If a text field delegate in the list is currently focused, remove the focus so that it
		// calls _changeVrmInstance() to save the new VRM instance value, before this checks
		// whether any VRM instances have changed.
		vrmInstancesListView.focus = false

		if (!classAndVrmInstanceModel.hasVrmInstanceChanges()) {
			return true
		}

		Global.dialogLayer.open(rebootDialogComponent)
		return false
	}

	ClassAndVrmInstanceModel { id: classAndVrmInstanceModel }

	GradientListView {
		id: vrmInstancesListView
		model: SortedClassAndVrmInstanceModel { sourceModel: classAndVrmInstanceModel }

		delegate: ListIntField {
			id: deviceDelegate

			readonly property int _modelVrmInstance: model.vrmInstance

			function revertText() {
				textField.text = model.vrmInstance
			}

			text: model.name
					? model.name
					  //: Name for an unconnected device. %1 = type of device
					  //% "Unconnected %1"
					: qsTrId("settings_vrm_device_instances_unconnected").arg(model.deviceClass)

			textField.inputMethodHints: Qt.ImhDigitsOnly
			textField.text: model.vrmInstance
			preferredVisible: model.deviceClass.length > 0 && model.vrmInstance >= 0
			validateInput: function() {
				const newVrmInstance = parseInt(textField.text)
				if (isNaN(newVrmInstance)) {
					return Utils.validationResult(VenusOS.InputValidation_Result_Error, CommonWords.error_nan.arg(textField.text))
				}
				return Utils.validationResult(VenusOS.InputValidation_Result_OK, "", newVrmInstance)
			}
			saveInput: function() {
				const newVrmInstance = parseInt(textField.text)
				if (newVrmInstance !== model.vrmInstance) {
					_changeVrmInstance(model.uid, model.deviceClass, newVrmInstance, revertText)
				}
			}
			on_ModelVrmInstanceChanged: {
				// If VRM instance is changed in the backend, reset the text.
				textField.text = _modelVrmInstance
			}
		}
	}

	Component {
		id: swapDialogComponent

		VrmInstanceSwapDialog {
			property var errorFunc

			function _callErrorFunc() {
				if (!!errorFunc) {
					errorFunc()
				}
				errorFunc = null
			}

			onRejected: _callErrorFunc()
			onSwapFailed: _callErrorFunc()
		}
	}

	Component {
		id: rebootDialogComponent

		ModalWarningDialog {
			//% "Reboot now?"
			title: qsTrId("settings_vrm_device_instances_reboot_now")

			//% "VRM instance changes will not be applied until the device is rebooted."
			description: qsTrId("settings_vrm_device_instances_reboot_now_description")

			onAboutToShow: {
				dialogDoneOptions = VenusOS.ModalDialog_DoneOptions_SetAndCancel
				acceptText = CommonWords.reboot
				//% "Close"
				rejectText = qsTrId("settings_vrm_device_instances_close")
			}

			tryAccept: function() {
				if (dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_OkOnly
						&& BackendConnection.type !== BackendConnection.DBusSource) {
					// In mqtt mode, user rebooted, and now clicked 'OK', so accept the dialog.
					return true
				}

				Global.venusPlatform.reboot()

				if (BackendConnection.type === BackendConnection.DBusSource) {
					//% "Device is rebooting..."
					description = qsTrId("settings_vrm_device_instances_rebooting")
				} else {
					//% "Device has been rebooted."
					description = qsTrId("settings_vrm_device_instances_rebooted")
				}

				root.tryPop = undefined
				dialogDoneOptions = VenusOS.ModalDialog_DoneOptions_OkOnly
				acceptText = CommonWords.ok

				if (BackendConnection.type === BackendConnection.DBusSource) {
					// Reboot takes a while to execute, so prevent any user activity until that happens.
					closePolicy = Popup.NoAutoClose
					footer.enabled = false
					footer.opacity = 0
				}
				return false
			}

			onRejected: {
				root.tryPop = undefined     // allow the next pop to proceed
				Global.pageManager.popPage()
			}
		}
	}
}
