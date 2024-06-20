/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: root

	property AcInputSystemInfo inputInfo

	readonly property bool connected: inputInfo && inputInfo.connected
	readonly property string serviceType: !!inputInfo ? inputInfo.serviceType : ""
	readonly property string serviceName: !!inputInfo ? inputInfo.serviceName : ""

	readonly property int source: !!inputInfo ? inputInfo.source : VenusOS.AcInputs_InputSource_NotAvailable
	readonly property alias gensetStatusCode: _acInputService.gensetStatusCode

	readonly property real power: _phases.totalPower
	readonly property real current: phases.count === 1 ? _phases.firstPhaseCurrent : NaN // multi-phase systems don't have a total current
	readonly property alias currentLimit: _acInputService.currentLimit
	readonly property alias phases: _phases

	// Phase measurements from com.victronenergy.system/Ac/ActiveIn/L<1|2|3>
	readonly property AcInputPhaseModel _phases: AcInputPhaseModel {
		id: _phases

		property int totalPower
		property real firstPhaseCurrent: count === 1 ? get(0).current : NaN

		readonly property Timer _timer: Timer { // timer needed so the display doesn't update too frequently
			interval: 1000
			repeat: true
			running: true
			onTriggered: {
				let sum = 0
				for (let i = 0; i < _phases.count; ++i) {
					sum += _phases.get(i).power || 0
				}
				_phases.totalPower = sum
			}
		}
	}

	// Data from the input-specific service, e.g. com.victronenergy.vebus for a VE.Bus input,
	// or com.victronenergy.grid for grid parallel systems.
	readonly property AcInputServiceLoader _acInputService: AcInputServiceLoader {
		id: _acInputService

		active: !!root.inputInfo
		serviceUid: root.serviceUid
		serviceType: root.serviceType
	}

	serviceUid: BackendConnection.type === BackendConnection.MqttSource
			  // this looks like: 'mqtt/vebus/289/'
			? inputInfo && serviceType.length && inputInfo.deviceInstance >= 0
					? "mqtt/" + serviceType + "/" + inputInfo.deviceInstance
					: ""
			  // this looks like: "dbus/com.victronenergy.vebus.ttyO1"
			: serviceName.length ? BackendConnection.uidPrefix() + "/" + serviceName : ""
}
