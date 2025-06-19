/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// Provides a generic DeviceModel for the specified service types.
//
// All services found for the specified types will be added and removed as Device objects.

DeviceModel {
	id: root

	property alias serviceTypes: serviceModel.serviceTypes

	property Component deviceDelegate: Device {
		id: device
		serviceUid: model.uid
		onValidChanged: {
			if (valid) {
				root.addDevice(device)
			} else {
				root.removeDevice(device.serviceUid)
			}
		}
	}

	readonly property Instantiator _objects: Instantiator {
		model: serviceModel
		delegate: root.deviceDelegate
	}

	readonly property ServiceModel _serviceModel: ServiceModel {
		id: serviceModel
	}
}
