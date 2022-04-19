/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
//import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {}

	property var _inputs: []

	function _getInputs() {
		const childIds = [] // veConfig.childIds

		let inputIds = []
		for (let i = 0; i < childIds.length; ++i) {
			let id = childIds[i]
			if (!isNaN(parseInt(id))) {
				inputIds.push(id)
			}
		}

		if (Utils.arrayCompare(_inputs, inputIds) !== 0) {
			_inputs = inputIds
		}
	}
/*
	VeQuickItem {
		id: veConfig
		uid: "dbus/com.victronenergy.system/Ac/In"
	}

	Connections {
		target: veConfig
		function onChildIdsChanged() { Qt.callLater(_getInputs) }
		Component.onCompleted: _getInputs()
	}
*/
	/*
	Each AC input has basic config details at com.victronenergy.system /Ac/In/x. E.g. for Input 0:
		/Ac/In/0/Connected: 			1
		/Ac/In/0/ServiceName: 		'com.victronenergy.grid.smappee_5400001427'
		/Ac/In/0/ServiceType: 		'grid'

	The ServiceName points to the service that provides more details for the input, e.g.
	com.victronenergy.vebus, com.victronenergy.grid, com.victronenergy.genset, which provides
	voltage, current, power etc. for the inputs.
	*/
	Instantiator {
		model: _inputs || null

		delegate: QtObject {
			id: input

			property string uid: modelData
			property string configUid: veConfig.uid + "/" + input.uid

			property string serviceType     // e.g. "vebus"
			property string serviceName     // e.g. "com.victronenergy.vebus.ttyO1"
			property int source
			property bool connected
			property int productId: -1

			// Detailed readings
			readonly property alias frequency: _serviceLoader.frequency
			readonly property alias current: _serviceLoader.current
			readonly property alias power: _serviceLoader.power
			readonly property alias voltage: _serviceLoader.voltage
			readonly property alias phases: _serviceLoader.phases

			property bool _valid: productId != -1
			on_ValidChanged: {
				const index = Utils.findIndex(root.model, input)
				if (_valid && index < 0) {
					root.model.append({ input: input })
				} else if (!_valid && index >= 0) {
					root.model.remove(index)
				}
			}

			property string _serviceUid: serviceName ? 'dbus/' + serviceName : ''

			// --- General config details about the input, from com.victronenergey.system ---
/*
			property VeQuickItem _serviceType: VeQuickItem {
				uid: configUid + "/ServiceType"
				onValueChanged: input.serviceType = value === undefined ? '' : value
			}
			property VeQuickItem _serviceName: VeQuickItem {
				uid: configUid + "/ServiceName"
				onValueChanged: input.serviceName = value === undefined ? '' : value
			}
			property VeQuickItem _source: VeQuickItem {
				uid: configUid + "/Source"
				onValueChanged: input.source = (value === undefined || value === '')
								? -1
								: parseInt(value)
			}
			property VeQuickItem _connected: VeQuickItem {
				uid: configUid + "/Connected"
				onValueChanged: input.connected = value === 1
			}

			// --- Further input details fetched from the service specific to this input. ---
			// e.g. from com.victronenergy.vebus, com.victronenergy.grid, etc.

			property VeQuickItem _productId: VeQuickItem {
				uid: _serviceUid ? _serviceUid + "/ProductId" : ''
				onValueChanged: input.productId = value === undefined ? false : value
			}
*/
			property AcInputServiceLoader _serviceLoader: AcInputServiceLoader {
				id: _serviceLoader

				serviceUid: input._serviceUid
				serviceType: input.serviceType

				// For vebus inputs, only the currently-active input has valid measurements, so
				// non-connected inputs should not show data.
				valid: serviceType == "vebus" ? input.connected : true
			}
		}
	}
}
