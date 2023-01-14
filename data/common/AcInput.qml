/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

QtObject {
	id: input

	property string systemServiceUid
	property string serviceUid

	readonly property string serviceType: _serviceType.value ? _serviceType.value : ''	// e.g. "vebus"
	readonly property int source: (_source.value === undefined || _source.value === '') ? -1 : parseInt(_source.value)
	readonly property bool connected: _connected.value === 1
	readonly property int productId: _productId.value ? _productId.value : -1
	readonly property int deviceInstance: _deviceInstance.value !== undefined ? _deviceInstance.value : -1

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

	readonly property VeQuickItem _serviceType: VeQuickItem {
		uid: systemServiceUid + "/ServiceType"
	}
	readonly property VeQuickItem _source: VeQuickItem {
		uid: systemServiceUid + "/Source"
	}
	readonly property VeQuickItem _connected: VeQuickItem {
		uid: systemServiceUid + "/Connected"
	}
	readonly property VeQuickItem _deviceInstance: VeQuickItem {
		uid: systemServiceUid + "/DeviceInstance"
	}

	readonly property VeQuickItem _productId: VeQuickItem {
		uid: serviceUid === '' ? '' : (serviceUid + '/ProductId')
	}

	property AcInputServiceLoader _serviceLoader: AcInputServiceLoader {
		id: _serviceLoader

		serviceUid: input.serviceUid
		serviceType: input.serviceType

		// For vebus inputs, only the currently-active input has valid measurements, so
		// non-connected inputs should not show data.
		valid: serviceType == "vebus" ? input.connected : true
	}
}
