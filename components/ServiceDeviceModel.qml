/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// Provides a generic DeviceModel for a specified service type.
//
// All services found for the specified type will be added and removed as Device objects.

DeviceModel {
	id: root

	required property string serviceType

	readonly property Instantiator _objects: Instantiator {
		model: modelLoader.item
		delegate: Device {
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
	}

	readonly property ServiceModelLoader modelLoader: ServiceModelLoader {
		serviceType: root.serviceType
	}
}
