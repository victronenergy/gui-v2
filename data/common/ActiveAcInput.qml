/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Units

Device {
	id: root

	readonly property bool connected: !!_activeInputInfo && _activeInputInfo.connected
	readonly property string serviceType: !!_activeInputInfo ? _activeInputInfo.serviceType : ""
	readonly property string serviceName: !!_activeInputInfo ? _activeInputInfo.serviceName : ""

	property int source: VenusOS.AcInputs_InputSource_NotAvailable
	readonly property alias gensetStatusCode: _acInputService.gensetStatusCode

	readonly property real power: _acInputService.hasTotalPower ? _acInputService.totalPower : _phases.totalPower
	readonly property real current: phases.count === 1 ? _phases.firstPhaseCurrent : NaN // multi-phase systems don't have a total current
	readonly property alias currentLimit: _acInputService.currentLimit
	readonly property alias phases: _phases

	property AcInputSystemInfo _activeInputInfo

	// AC input metadata from com.victronenergy.system/Ac/In/<1|2>
	property Instantiator _inputInfoObjects: Instantiator {
		model: VeQItemTableModel {
			uids: [Global.system.serviceUid + "/Ac/In"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: AcInputSystemInfo {
			id: infoObject

			bindPrefix: model.uid
			onConnectedChanged: {
				if (connected) {
					root._activeInputInfo = infoObject
				} else if (root._activeInputInfo === infoObject) {
					root._activeInputInfo = null
				}
			}
		}
	}

	// Phase measurements from com.victronenergy.system/Ac/ActiveIn/L<1|2|3>
	readonly property AcInputPhaseModel _phases: AcInputPhaseModel {
		id: _phases

		property real totalPower: NaN
		property real firstPhaseCurrent: NaN

		onPhaseValueChanged: function(phaseIndex, propertyName, propertyValue) {
			if (propertyName === "power" && !root._acInputService.hasTotalPower) {
				let total = NaN
				for (let i = 0; i < phases.count; ++i) {
					if (i === phaseIndex) {
						total = Units.sumRealNumbers(total, propertyValue)
					} else {
						const phase = get(phaseIndex)
						total = Units.sumRealNumbers(total, phase ? phase[propertyName] : NaN)
					}
				}
				totalPower = total
			} else if (propertyName === "current" && count === 1) {
				firstPhaseCurrent = propertyValue
			}
		}
	}

	// Data from the input-specific service, e.g. com.victronenergy.vebus for a VE.Bus input,
	// or com.victronenergy.grid for grid parallel systems.
	readonly property AcInputServiceLoader _acInputService: AcInputServiceLoader {
		id: _acInputService

		serviceUid: root.serviceUid
		serviceType: root.serviceType
	}

	serviceUid: BackendConnection.type === BackendConnection.MqttSource
			  // this looks like: 'mqtt/vebus/289/'
			? _activeInputInfo && serviceType.length && _activeInputInfo.deviceInstance >= 0
					? "mqtt/" + serviceType + "/" + _activeInputInfo.deviceInstance
					: ""
			  // this looks like: "dbus/com.victronenergy.vebus.ttyO1"
			: serviceName.length ? BackendConnection.uidPrefix() + serviceName : ""
}
