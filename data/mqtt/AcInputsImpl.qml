/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var _inputs: []

	function _getInputs() {
		let inputIds = []
		for (let i = 0; i < veSystemAcIn.count; ++i) {
			const uid = veSystemAcIn.objectAt(i).uid
			const id = uid.substring(uid.lastIndexOf('/') + 1)
			if (!isNaN(parseInt(id))) {
				inputIds.push(uid)
			}
		}
		if (Utils.arrayCompare(_inputs, inputIds) !== 0) {
			_inputs = inputIds
		}
	}

	property Instantiator veSystemAcIn: Instantiator {
		model: VeQItemTableModel {
			property SingleUidHelper uidHelper: SingleUidHelper {
				dbusUid: "dbus/com.victronenergy.system/Dc/Battery/Power"
			}
			uids: [uidHelper.mqttUid]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: QtObject {
			property var uid: model.uid
		}

		onCountChanged: Qt.callLater(root._getInputs)
	}

	/*
	Each AC input has basic config details at com.victronenergy.system /Ac/In/x. E.g. for Input 0:
		/Ac/In/0/Connected: 			1
		/Ac/In/0/ServiceName: 		'com.victronenergy.grid.smappee_5400001427'
		/Ac/In/0/ServiceType: 		'grid'

	The ServiceName points to the service that provides more details for the input, e.g.
	com.victronenergy.vebus, com.victronenergy.grid, com.victronenergy.genset, which provides
	voltage, current, power etc. for the inputs.
	*/
	property Instantiator inputObjects: Instantiator {
		model: _inputs || null

		delegate: QtObject {
			id: input

			property string configUid: modelData

			property string serviceType     // e.g. "vebus"
			property string serviceName     // e.g. "vebus.ttyO1"
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
				const index = Utils.findIndex(Global.acInputs.model, input)
				if (_valid && index < 0) {
					Global.acInputs.addInput(input)
				} else if (!_valid && index >= 0) {
					Global.acInputs.removeInput(index)
				}
			}

			onConnectedChanged: {
				if (connected) {
					Global.acInputs.connectedInput = input
				} else if (!connected && Global.acInputs.connectedInput === input) {
					Global.acInputs.connectedInput = null
				}
			}

			onSourceChanged: {
				if (source === VenusOS.AcInputs_InputType_Generator) {
					Global.acInputs.generatorInput = input
				} else if (Global.acInputs.generatorInput === input) {
					Global.acInputs.generatorInput = null
				}
			}

			// --- General config details about the input, from com.victronenergy.system ---

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

			property string _serviceUid: serviceName ? 'dbus/com.victronenergy.' + serviceName : ''

			property VeQuickItem _productId: VeQuickItem {
				property SingleUidHelper uidHelper: SingleUidHelper {
					dbusUid: input._serviceUid ? input._serviceUid + "/ProductId" : ''
				}
				uid: uidHelper.mqttUid
				onValueChanged: input.productId = value === undefined ? false : value
			}

			property AcInputServiceLoader _serviceLoader: AcInputServiceLoader {
				id: _serviceLoader

				property SingleUidHelper uidHelper: SingleUidHelper {
					dbusUid: input.serviceName ? 'mqtt/' + input.serviceName : ''
				}

				serviceUid: uidHelper.mqttUid
				serviceType: input.serviceType

				// For vebus inputs, only the currently-active input has valid measurements, so
				// non-connected inputs should not show data.
				valid: serviceType == "vebus" ? input.connected : true
			}
		}
	}
}
