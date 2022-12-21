/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

QtObject {
	id: root

	/*
	Each AC input has basic config details at com.victronenergy.system /Ac/In/x. E.g. for Input 0:
		/Ac/In/0/Connected {"value": 0}
		/Ac/In/0/DeviceInstance {"value": 289}
		/Ac/In/0/ServiceName {"value": "com.victronenergy.vebus.ttyUSB1"}
		/Ac/In/0/ServiceType {"value": "vebus"}
		/Ac/In/0/Source {"value": 3}

	The ServiceName points to the service that provides more details for the input, e.g.
	vebus, grid, genset, which provides voltage, current, power etc. for the inputs.
	*/
	property Instantiator inputObjects: Instantiator {

		/* model uids will look like this:
			uid: mqtt/system/0/Ac/In/0					// we want this one
			uid: mqtt/system/0/Ac/In/1					// we want this one
			uid: mqtt/system/0/Ac/In/NumberOfAcInputs	// we don't want this one
		*/
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.IdRole
			filterRegExp: "[0-9]+"

			model: VeQItemTableModel {
				uids: ["mqtt/system/0/Ac/In"]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}

		delegate: QtObject {
			id: input

			property string configUid: model.uid

			property string serviceType: _serviceType.value ? _serviceType.value : ''	// e.g. "vebus"
			property int source: (_source.value === undefined || _source.value === '') ? -1 : parseInt(_source.value)
			property bool connected: _connected.value === 1
			property int productId: _productId.value ? _productId.value : -1
			property int deviceInstance: _deviceInstance.value ? _deviceInstance.value : -1

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
			}
			property VeQuickItem _source: VeQuickItem {
				uid: configUid + "/Source"
			}
			property VeQuickItem _connected: VeQuickItem {
				uid: configUid + "/Connected"
			}
			property VeQuickItem _deviceInstance: VeQuickItem {
				uid: configUid + "/DeviceInstance"
			}

			// this looks like: 'mqtt/vebus/289/'
			property string _serviceUid: serviceType !== '' && deviceInstance !== '' ? 'mqtt/' + serviceType + '/' + deviceInstance : ''

			property VeQuickItem _productId: VeQuickItem {
				uid: _serviceUid === '' ? '' : _serviceUid + '/ProductId'
			}

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
