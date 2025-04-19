/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
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
		const conflictingDeviceIndex = classAndVrmInstanceModel.findByClassAndVrmInstance(deviceClass, newVrmInstance)
		if (conflictingDeviceIndex >= 0) {
			// Show a dialog to confirm whether to swap device instances with the conflicting one.
			const maximumVrmInstance = classAndVrmInstanceModel.maximumVrmInstance(deviceClass)
			const dialogParams = {
				instanceAUid: uid,
				instanceBUid: classAndVrmInstanceModel.get(conflictingDeviceIndex).uid,
				temporaryVrmInstance: isNaN(maximumVrmInstance) ? 0 : maximumVrmInstance + 1,
				errorFunc: errorFunc,
			}
			Global.dialogLayer.open(swapDialogComponent, dialogParams)
			return false
		} else {
			// No conflicts; just set the new VRM instance.
			vrmInstanceItem.uid = uid
			vrmInstanceItem.setValue(deviceClass + ":" + newVrmInstance)
			return true
		}
	}

	function _findDeviceObject(deviceClass, deviceInstance) {
		if (deviceInstance < 0) {
			return null
		}

		for (let i = 0; i < Global.allDevicesModel.count; ++i) {
			const device = Global.allDevicesModel.deviceAt(i)
			if (device
					&& device.deviceInstance === deviceInstance
					&& BackendConnection.serviceTypeFromUid(device.serviceUid) === deviceClass) {
				return device
			}
		}
		return null
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

	VeQuickItem { id: vrmInstanceItem }

	// Creates an object for each /Devices/.../ClassAndVrmInstance entry, and populates
	// classAndVrmInstanceModel with the data for each object. This is better than creating the
	// ListView directly from the /ClassAndVrmInstance entries, as that would create/destroy the
	// VeQuickItem objects when delegates are created/destroyed, and then VRM instance values would not
	// always be available for comparison.
	Instantiator {
		id: classAndVrmInstanceObjects

		model: VeQItemTableModel {
			uids: [ Global.systemSettings.serviceUid + "/Settings/Devices" ]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: ClassAndVrmInstance {
			uid: model.uid + "/ClassAndVrmInstance"
			customNameUid: model.uid + "/CustomName"

			onVrmInstanceChanged: {
				const modelIndex = classAndVrmInstanceModel.findByUid(uid)
				if (modelIndex >= 0) {
					classAndVrmInstanceModel.set(modelIndex, { deviceClass: deviceClass, vrmInstance: vrmInstance })
					classAndVrmInstanceModel.updateSortOrder(modelIndex)
				}

				// Try to find/create a Device in order to fetch the device name. Once initialized,
				// it can remain the same, since the device is determined by the 'real' device
				// instance, rather than the VRM instance.
				if (vrmInstance < 0) {
					device = null
				} else if (!device) {
					device = root._findDeviceObject(deviceClass, vrmInstance)
					if (!device) {
						console.warn("Failed to find service for device class", deviceClass, "with device instance:", vrmInstance)
					}
				}
			}

			onNameChanged: {
				const modelIndex = classAndVrmInstanceModel.findByUid(uid)
				if (modelIndex >= 0) {
					classAndVrmInstanceModel.setProperty(modelIndex, "name", name)
					classAndVrmInstanceModel.updateSortOrder(modelIndex)
				}
			}
		}

		onObjectAdded: function(index, object) {
			const insertionIndex = classAndVrmInstanceModel.findInsertionIndex(object.deviceClass, object.name, object.vrmInstance)
			classAndVrmInstanceModel.insert(insertionIndex, {
				uid: object.uid,
				deviceClass: object.deviceClass,
				vrmInstance: object.vrmInstance,
				initialVrmInstance: object.vrmInstance,
				savedVrmInstance: object.vrmInstance,
				name: object.name
			})
		}
	}

	// A model of the data to be shown in the main list view.
	ListModel {
		id: classAndVrmInstanceModel

		function findByClassAndVrmInstance(deviceClass, vrmInstance) {
			for (let i = 0; i < count; ++i) {
				const data = get(i)
				if (data.deviceClass === deviceClass && data.vrmInstance === vrmInstance) {
					return i
				}
			}
			return -1
		}

		function findByUid(uid) {
			for (let i = 0; i < count; ++i) {
				const data = get(i)
				if (data.uid === uid) {
					return i
				}
			}
			return -1
		}

		function findInsertionIndex(deviceClass, name, vrmInstance) {
			// Sort by connected devices first (i.e. those with a name), then by device class, then
			// by name or VRM instance.
			const deviceConnected = name.length > 0
			for (let i = 0; i < count; ++i) {
				const data = get(i)
				const currentDeviceConnected = data.name.length > 0
				if (deviceConnected) {
					if (!currentDeviceConnected) {
						return i
					}
					if (data.deviceClass > deviceClass) {
						return i
					} else if (data.deviceClass === deviceClass && data.name.localeCompare(name) > 0) {
						return i
					}
				} else {
					if (currentDeviceConnected) {
						continue
					}
					if (data.deviceClass > deviceClass) {
						return i
					} else if (data.deviceClass === deviceClass && data.vrmInstance > vrmInstance) {
						return i
					}
				}
			}
			return count
		}

		function updateSortOrder(modelIndex) {
			const data = get(modelIndex)
			const insertionIndex = findInsertionIndex(data.deviceClass, data.name, data.vrmInstance)
			if (insertionIndex !== modelIndex) {
				move(modelIndex, insertionIndex, 1)
			}
		}

		function maximumVrmInstance(deviceClass) {
			let maxValue = NaN
			for (let i = 0; i < count; ++i) {
				const data = get(i)
				if (data.deviceClass === deviceClass && !isNaN(data.vrmInstance)) {
					maxValue = isNaN(maxValue) ? data.vrmInstance : Math.max(maxValue, data.vrmInstance)
				}
			}
			return maxValue
		}

		function hasVrmInstanceChanges() {
			for (let i = 0; i < count; ++i) {
				const modelData = get(i)
				if (modelData.savedVrmInstance !== modelData.initialVrmInstance
						|| modelData.vrmInstance !== modelData.initialVrmInstance) {
					return true
				}
			}
			return false
		}
	}

	GradientListView {
		id: vrmInstancesListView
		model: classAndVrmInstanceModel

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
					if (root._changeVrmInstance(model.uid, model.deviceClass, newVrmInstance, revertText)) {
						// Set a "savedVrmInstance" value so that hasVrmInstanceChanges() will
						// detect a change even if the new value has not yet been saved to the
						// backend.
						classAndVrmInstanceModel.setProperty(model.index, "savedVrmInstance", newVrmInstance)
					}
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
					closePolicy = C.Popup.NoAutoClose
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
