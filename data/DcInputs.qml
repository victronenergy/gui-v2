/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	enum InputType {
		UnknownType = 0,
		Alternator = 1,
		DcGenerator = 2,
		Wind = 3
	}

	property ListModel model: ListModel {}

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
					return DcInputs.InputType.Alternator
				} else if (uid.startsWith("com.victronenergy.fuelcell.")) {
					return DcInputs.InputType.FuelCell
				} if (uid.startsWith("com.victronenergy.dcsource.")) {
					// TODO should check some type value from com.victronenergy.dcsource
					return DcInputs.InputType.UnknownType
				}
			}

			property real voltage
			property real current
			property real temperature

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
		}
	}
}
