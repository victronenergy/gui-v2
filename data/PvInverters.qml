/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "pvInverters"
	}

	function addInverter(inverter) {
		model.addDevice(inverter)
	}

	function removeInverter(inverter) {
		model.removeDevice(inverter.serviceUid)
	}

	function reset() {
		model.clear()
	}

	Component.onCompleted: Global.pvInverters = root
}
