/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

Device {
	id: input

	// dbus/com.victronenergy.system/Ac/In/<x> or mqtt/system/Ac/In/<x>
	property string systemServicePrefix

	readonly property string serviceType: _serviceType.value ? _serviceType.value : ''	// e.g. "vebus"
	readonly property int source: (_source.value === undefined || _source.value === '') ? -1 : parseInt(_source.value)
	readonly property bool connected: _connected.value === 1
	readonly property int gensetStatusCode: _gensetStatusCode.value === undefined ? -1 : _gensetStatusCode.value

	// Detailed readings
	readonly property alias frequency: _serviceLoader.frequency
	readonly property alias current: _serviceLoader.current
	readonly property alias currentLimit: _serviceLoader.currentLimit
	readonly property alias power: _serviceLoader.power
	readonly property alias voltage: _serviceLoader.voltage
	readonly property alias phases: _serviceLoader.phases

	onConnectedChanged: {
		if (!!Global.acInputs) {
			if (connected) {
				Global.acInputs.connectedInput = input
			} else if (!connected && Global.acInputs.connectedInput === input) {
				Global.acInputs.connectedInput = null
			}
		}
	}

	onSourceChanged: {
		if (!!Global.acInputs) {
			if (source === VenusOS.AcInputs_InputType_Generator) {
				Global.acInputs.generatorInput = input
			} else if (Global.acInputs.generatorInput === input) {
				Global.acInputs.generatorInput = null
			}
		}
	}

	// --- General config details about the input, from com.victronenergy.system ---

	readonly property VeQuickItem _serviceType: VeQuickItem {
		uid: input.systemServicePrefix + "/ServiceType"
	}
	readonly property VeQuickItem _source: VeQuickItem {
		uid: input.systemServicePrefix + "/Source"
	}
	readonly property VeQuickItem _connected: VeQuickItem {
		uid: input.systemServicePrefix + "/Connected"
	}

	// StatusCode is only valid for genset devices
	readonly property VeQuickItem _gensetStatusCode: VeQuickItem {
		uid: input.serviceType === "genset" ? input.serviceUid + "/StatusCode" : ""
	}

	property AcInputServiceLoader _serviceLoader: AcInputServiceLoader {
		id: _serviceLoader

		serviceUid: input.serviceUid
		serviceType: input.serviceType

		// For vebus inputs, only the currently-active input has valid measurements, so
		// non-connected inputs should not show data.
		valid: serviceType == "vebus" ? input.connected : true
	}

	onValidChanged: {
		if (!!Global.acInputs) {
			if (valid) {
				Global.acInputs.addInput(input)
			} else {
				Global.acInputs.removeInput(input)
			}
		}
	}
}
