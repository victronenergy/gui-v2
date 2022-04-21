/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {}

	property var _monitorModes: ({
		"-1": Enums.DcInputs_InputType_DcGenerator,
		// -2 AC charger
		// -3 DC charger
		// -4 Water generator
		// -7 Shaft generator
		// -8 Wind charger
		"-8": Enums.DcInputs_InputType_Wind,
	})

	property var _inputs: []

	function _getInputs() {
		const childIds = veDBus.childIds

		let inputIds = []
		for (let i = 0; i < childIds.length; ++i) {
			let id = childIds[i]
			if (id.startsWith("com.victronenergy.alternator.")
					|| id.startsWith("com.victronenergy.fuelcell.")
					|| id.startsWith("com.victronenergy.dcsource.")) {
				inputIds.push(id)
			}
		}

		if (Utils.arrayCompare(_inputs, inputIds) !== 0) {
			_inputs = inputIds
		}
	}

	Connections {
		target: veDBus
		function onChildIdsChanged() { Qt.callLater(_getInputs) }
		Component.onCompleted: _getInputs()
	}


	Instantiator {
		model: _inputs || null

		delegate: QtObject {
			id: input

			property string uid: modelData
			property string serviceUid: "dbus/" + modelData

			property int source: {
				if (uid.startsWith("com.victronenergy.alternator.")) {
					return Enums.DcInputs_InputType_Alternator
				} else if (uid.startsWith("com.victronenergy.fuelcell.")) {
					return Enums.DcInputs_InputType_FuelCell
				} if (uid.startsWith("com.victronenergy.dcsource.")) {
					// Use DC Generator as the catch-all type for any DC power source that isn't
					// specifically handled.
					return root._monitorModes[monitorMode.toString()] || Enums.DcInputs_InputType_DcGenerator
				}
			}

			property real voltage
			property real current
			property real temperature
			property int monitorMode

			Component.onCompleted: {
				root.model.append({ input: input })
			}
			Component.onDestruction: {
				const index = Utils.findIndex(root.model, input)
				if (index >= 0) {
					root.model.remove(index)
				}
			}

			property var _voltage: VeQuickItem {
				uid: input.serviceUid + "/Dc/0/Voltage"
				onValueChanged: input.voltage = value === undefined ? NaN : value
			}

			property var _current: VeQuickItem {
				uid: input.serviceUid + "/Dc/0/Current"
				onValueChanged: input.current = value === undefined ? NaN : value
			}

			property var _temperature: VeQuickItem {
				uid: input.serviceUid + "/Dc/0/Temperature"
				onValueChanged: input.temperature = value === undefined ? NaN : value
			}

			property var _monitorMode: VeQuickItem {
				uid: input.serviceUid + "/Settings/MonitorMode"
				onValueChanged: input.monitorMode = value === undefined ? NaN : value
			}
		}
	}
}
