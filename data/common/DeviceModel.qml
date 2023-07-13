/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQml

/*
  A base model for storing a collection of devices.

  Each device object is expected to have:
	- serviceUid, used to identify the object within the model
	- deviceInstance, used to insert the object in sorted order
*/

ListModel {
	id: root

	property string objectProperty
	property var firstObject    // the object with the lowest DeviceInstance

	function addObject(object) {
		if (!objectProperty) {
			console.warn("cannot add object, objectProperty not set!")
			return
		}
		if (!object || !object.serviceUid) {
			console.warn(objectProperty, "model cannot add object without serviceUid!")
			return false
		}
		if (indexOf(object.serviceUid) >= 0) {
			console.warn(objectProperty, "model not adding object, already contains", object.serviceUid)
			return false
		}

		let insertionIndex = count
		const deviceInstance = object.deviceInstance.value
		if (deviceInstance === undefined || deviceInstance < 0) {
			console.warn(objectProperty, "model cannot add object", object.serviceUid, "invalid device instance:", deviceInstance)
			return false
		}
		for (let i = 0; i < count; ++i) {
			const currentDeviceInstance = get(i)[objectProperty].deviceInstance.value
			if (currentDeviceInstance === undefined || currentDeviceInstance < 0) {
				console.warn(objectProperty, "model found invalid device instance at index", i)
				continue
			}
			if (deviceInstance < currentDeviceInstance) {
				insertionIndex = i
				break
			}
		}
		let data = {}
		data[objectProperty] = object
		insert(insertionIndex, data)
		_refreshFirstObject()
		return true
	}

	function removeObject(serviceUid) {
		if (!serviceUid) {
			console.warn(objectProperty, "model cannot remove invalid serviceUid!")
			return false
		}
		const index = indexOf(serviceUid)
		if (index >= 0) {
			remove(index)
			_refreshFirstObject()
			return true
		}
		return false
	}

	function indexOf(serviceUid) {
		for (let i = 0; i < count; ++i) {
			const object = get(i)[objectProperty]
			if (object && object.serviceUid === serviceUid) {
				return i
			}
		}
		return -1
	}

	function objectForDeviceInstance(deviceInstance) {
		for (let i = 0; i < count; ++i) {
			const object = get(i)[objectProperty]
			if (object && object.deviceInstance.value === deviceInstance) {
				return object
			}
		}
		return null
	}

	function objectAt(index) {
		if (index < 0 || index >= count) {
			console.warn(objectProperty, "objectAt(): invalid index", index)
			return null
		}
		return get(index)[objectProperty]
	}

	function totalValues(propertyNames) {
		let totals = {}
		let propertyIndex
		for (propertyIndex = 0; propertyIndex < propertyNames.length; ++propertyIndex) {
			totals[propertyNames[propertyIndex]] = NaN
		}
		for (let i = 0; i < count; ++i) {
			const object = objectAt(i)
			for (propertyIndex = 0; propertyIndex < propertyNames.length; ++propertyIndex) {
				const propertyName = propertyNames[propertyIndex]
				const value = object[propertyName]
				if (!isNaN(value)) {
					if (isNaN(totals[propertyName])) {
						totals[propertyName] = 0
					}
					totals[propertyName] += value
				}
			}
		}
		return totals
	}

	function _refreshFirstObject() {
		firstObject = count === 0 ? null : objectAt(0)
	}
}
