/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// Provides a generic DeviceModel for a set of service types.
//
// All services found for the specified types will be added and removed as Device objects.

DeviceModel {
	id: root

	required property var serviceTypes

	readonly property Instantiator _serviceObjects: Instantiator {
		model: root.serviceTypes
		delegate: Instantiator {
			required property string modelData
			readonly property ServiceModelLoader modelLoader: ServiceModelLoader {
				serviceType: modelData
			}

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
	}
}
