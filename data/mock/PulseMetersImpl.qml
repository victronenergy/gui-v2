/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function populate() {
		Global.pulseMeters.model.addDevice(pulseMeterComponent.createObject(root))
	}

	property Component pulseMeterComponent: Component {
		MockDevice {
			property real aggregate: 101

			serviceUid: "mock/com.victronenergy.pulsemeter.ttyUSB" + deviceInstance
			name: "PulseMeter" + deviceInstance
		}
	}

	Component.onCompleted: {
		populate()
	}
}
