/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

// Allows VRM instances to be changed for devices on the system.
//
// Every device has a device-class:vrm-instance pair, stored as:
// - (dbus) com.victronenergy.settings/Settings/Devices/<unique device identifier>/ClassAndVrmInstance
// - (mqtt) W/<portalId>/settings/0/Settings/Devices/<unique device identifier>/ClassAndVrmInstance
//
// VRM instances must be unique among devices with the same type (device class). If the user tries
// to use an existing instance for that type, a dialog will appear to prompt an instance swap.
//
// Device classes may be short ('solarcharger') or long ('com.victronenergy.solarcharger'),
// regardless of whether the app is running on dbus or mqtt. They may or may not map directly to
// mqtt entries; e.g. the 'analog' device class refers to both tanks and temperature devices.
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

	property var _swapDialog
	property var _rebootDialog

	function _changeVrmInstance(index, newVrmInstance, errorFunc) {
		// See if another device of this class already has this VRM instance.
		const modelData = classAndVrmInstanceModel.get(index)
		const conflictingDeviceIndex = classAndVrmInstanceModel.findByClassAndVrmInstance(modelData.deviceClass, newVrmInstance)
		if (conflictingDeviceIndex >= 0) {
			// Show a dialog to confirm whether to swap device instances with the conflicting one.
			if (!_swapDialog) {
				_swapDialog = swapDialogComponent.createObject(root)
			}
			const maximumVrmInstance = classAndVrmInstanceModel.maximumVrmInstance(modelData.deviceClass)

			_swapDialog.instanceA = classAndVrmInstanceObjects.objectAt(index)
			_swapDialog.instanceB = classAndVrmInstanceObjects.objectAt(conflictingDeviceIndex)
			_swapDialog.temporaryVrmInstance = isNaN(maximumVrmInstance) ? 0 : maximumVrmInstance + 1
			_swapDialog.errorFunc = errorFunc
			_swapDialog.open()
		} else {
			// No conflicts; just set the new VRM instance.
			classAndVrmInstanceObjects.objectAt(index).setVrmInstance(newVrmInstance)
			_setConfirmRebootOnPop()
		}
	}

	function _findDeviceObject(deviceClass, deviceInstance) {
		const deviceModels = Global.deviceModelsForClass(deviceClass)
		if (deviceModels.length === 0) {
			return null
		}
		for (let i = 0; i < deviceModels.length; ++i) {
			const device = deviceModels[i].deviceForDeviceInstance(deviceInstance)
			if (device) {
				return device
			}
		}
		return null
	}

	function _confirmStackPop() {
		if (!_rebootDialog) {
			_rebootDialog = rebootDialogComponent.createObject(root)
		}
		_rebootDialog.open()
		return false
	}

	function _setConfirmRebootOnPop() {
		// If user changes the VRM instance, ask whether reboot should be done when page is popped.
		tryPop = _confirmStackPop
	}

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
			property var mqttDevice: Device { }

			uid: model.uid + "/ClassAndVrmInstance"

			function _resetDevice(deviceId) {
				const deviceInstance = Utils.deviceInstanceForDeviceId(deviceId)
				if (deviceInstance < 0) {
					console.warn("No device instance found for device:", deviceId)
					return
				}
				// First, try to match with an existing device from the Global data models.
				device = root._findDeviceObject(deviceClass, deviceInstance)
				if (device) {
					return
				}
				if (BackendConnection.type === BackendConnection.DBusSource) {
					// If in dbus mode, try to match against the root dbus service uids, which are
					// named "com.victronenergy.*". This should find a match.
					const serviceUidPrefix = deviceClass.startsWith("com.victronenergy.")
							? deviceClass
							: "com.victronenergy." + deviceClass
					device = dbusServiceModel.findDeviceByPrefixAndDeviceInstance(serviceUidPrefix, deviceInstance)
					if (!device) {
						console.warn("Failed to find service for device class", deviceClass,
								"with device instance:", deviceInstance)
					}
				} else if (BackendConnection.type === BackendConnection.MqttSource) {
					// If in mqtt mode, try to match against mqtt/<device-class>/<instance>, where
					// <device-class> should not contain a com.victronenergy prefix. This may or may
					// not find a match, as some device classes do not map directly to services.
					const serviceType = deviceClass.startsWith("com.victronenergy.")
							? deviceClass.substring("com.victronenergy.".length)
							: deviceClass
					mqttDevice.serviceUid = "mqtt/" + serviceType + "/" + deviceInstance
					device = mqttDevice
				}
			}

			onVrmInstanceChanged: {
				const deviceId = model.uid.substring(model.uid.lastIndexOf('/') + 1)
				if (!deviceId) {
					console.warn("Malformed device id!", deviceId)
					return
				}
				const modelIndex = classAndVrmInstanceModel.findByUid(uid)
				if (modelIndex >= 0) {
					classAndVrmInstanceModel.set(modelIndex, { deviceClass: deviceClass, vrmInstance: vrmInstance })
					classAndVrmInstanceModel.updateSortOrder(modelIndex)
				}
				Utils.updateOrInitDeviceVrmInstance(deviceId, vrmInstance)

				// Try to find/create a Device in order to fetch the device name. Once initialized,
				// it can remain the same, since the device is determined by the 'real' device
				// instance, rather than the VRM instance.
				if (vrmInstance < 0) {
					device = null
				} else if (!device) {
					_resetDevice(deviceId)
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

		function updateSortOrder(index) {
			const data = get(index)
			const insertionIndex = findInsertionIndex(data.deviceClass, data.name, data.vrmInstance)
			if (insertionIndex !== modelIndex) {
				move(index, insertionIndex, 1)
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
	}

	GradientListView {
		model: classAndVrmInstanceModel

		delegate: ListTextField {
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
			visible: model.deviceClass.length > 0 && model.vrmInstance >= 0

			onAccepted: {
				const newVrmInstance = parseInt(textField.text)
				if (isNaN(newVrmInstance)) {
					console.warn("Cannot change device instance, bad value:", newVrmInstance)
					return
				}
				root._changeVrmInstance(model.index, newVrmInstance, revertText)
			}

			on_ModelVrmInstanceChanged: {
				// If VRM instance is changed in the backend, reset the text.
				textField.text = _modelVrmInstance
			}
		}
	}

	// A list of Device objects, matched to each service in the list of root dbus services. Not
	// needed for mqtt, where 'mqtt/service-type/device-instance' can be used to find the service.
	ListModel {
		id: dbusServiceModel

		function findDeviceByPrefixAndDeviceInstance(serviceUidPrefix, deviceInstance) {
			for (let i = 0; i < count; ++i) {
				const data = get(i)
				if (data.serviceUid.startsWith(serviceUidPrefix)
						&& data.device.deviceInstance === deviceInstance) {
					return data.device
				}
			}
			return null
		}

		property var _deviceBuilder: Instantiator {
			model: BackendConnection.type === BackendConnection.DBusSource ? Global.dataServiceModel : null
			delegate: Device {
				serviceUid: model.uid
			}
			onObjectAdded: function(index, object) {
				dbusServiceModel.append({ serviceUid: object.serviceUid, device: object })
			}
			onObjectRemoved: function(index, object) {
				for (let i = 0; i < dbusServiceModel.count; ++i) {
					if (dbusServiceModel.get(i).serviceUid === object.serviceUid) {
						dbusServiceModel.remove(i)
						break
					}
				}
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

			onAccepted: root._setConfirmRebootOnPop()
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
				dialogDoneOptions = VenusOS.ModalDialog_DoneOptions_SetAndClose
				acceptText = CommonWords.reboot
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
