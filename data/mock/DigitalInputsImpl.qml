/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function setMockValue(key, value) {
		Global.mockDataSimulator.setMockValue("com.victronenergy.digitalinputs/" + key, value)
	}

	function addInput(name, label, type) {
		setMockValue(`Devices/${name}/Label`, label)
		setMockValue(`Devices/${name}/Type`, type)
	}

	Component.onCompleted: {
		// Add inputs that are not sorted by label; the integrations page should sort them when
		// displayed.
		addInput(1, "Digital input B", VenusOS.DigitalInput_Type_PulseMeter)
		addInput(2, "Digital input A", VenusOS.DigitalInput_Type_DoorAlarm)
		addInput("HQ2502NXCMN_input_1", "GX IO ext. HQ2502NXCMN - Digital input Z", 0)
		addInput("HQ2502NXCMN_input_2", "GX IO ext. HQ2502NXCMN - Digital input Y", 0)

		// Add an invalid entry that should not be shown on the integrations page.
		addInput(3, undefined, undefined)
	}
}
