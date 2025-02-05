/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: pvInverter

	readonly property int statusCode: _statusCode.isValid ? _statusCode.value : -1
	readonly property int errorCode: _errorCode.isValid ? _errorCode.value : -1

	readonly property real energy: _energy.isValid ? _energy.value : NaN
	readonly property real power: _power.isValid ? _power.value : NaN
	readonly property real current: _validSinglePhase ? _validSinglePhase.current : NaN
	readonly property real voltage: _validSinglePhase ? _validSinglePhase.voltage : NaN

	readonly property PhaseModel phases: PhaseModel {
		function updateCount(maxPhaseCount) {
			// pvinverter services do not have /NumberOfPhases, so manually update the phase model
			// count when phase measurements are detected.
			phaseCount = Math.max(count, maxPhaseCount)
		}

		function getPhase(index) {
			return _phases.objectAt(index)
		}

		readonly property Instantiator _phases: Instantiator {
			model: 3
			delegate: QtObject {
				required property int index
				readonly property string phaseUid: pvInverter.serviceUid + "/Ac/L" + (index + 1)

				readonly property string name: "L" + (index + 1)
				readonly property real energy: _phaseEnergy.isValid ? _phaseEnergy.value : NaN
				readonly property real power: _phasePower.isValid ? _phasePower.value : NaN
				readonly property real current: _phaseCurrent.isValid ? _phaseCurrent.value : NaN
				readonly property real voltage: _phaseVoltage.isValid ? _phaseVoltage.value : NaN
				readonly property bool isValid: _phaseCurrent.isValid && _phaseVoltage.isValid

				readonly property VeQuickItem _phaseEnergy: VeQuickItem {
					uid: phaseUid + "/Energy/Forward"
					onIsValidChanged: if (isValid) phases.updateCount(index + 1)
					onValueChanged: phases.setValue(index, PhaseModel.EnergyRole, value)
				}
				readonly property VeQuickItem _phasePower: VeQuickItem {
					uid: phaseUid + "/Power"
					onIsValidChanged: if (isValid) phases.updateCount(index + 1)
					onValueChanged: phases.setValue(index, PhaseModel.PowerRole, value)
				}
				readonly property VeQuickItem _phaseCurrent: VeQuickItem {
					uid: phaseUid + "/Current"
					onIsValidChanged: if (isValid) phases.updateCount(index + 1)
					onValueChanged: phases.setValue(index, PhaseModel.CurrentRole, value)
				}
				readonly property VeQuickItem _phaseVoltage: VeQuickItem {
					uid: phaseUid + "/Voltage"
					onIsValidChanged: if (isValid) phases.updateCount(index + 1)
					onValueChanged: phases.setValue(index, PhaseModel.VoltageRole, value)
				}
			}
		}
	}

	readonly property VeQuickItem _statusCode: VeQuickItem {
		uid: pvInverter.serviceUid + "/StatusCode"
	}

	readonly property VeQuickItem _errorCode: VeQuickItem {
		uid: pvInverter.serviceUid + "/ErrorCode"
	}

	readonly property VeQuickItem _energy: VeQuickItem {
		uid: pvInverter.serviceUid + "/Ac/Energy/Forward"
	}

	readonly property VeQuickItem _power: VeQuickItem {
		uid: pvInverter.serviceUid + "/Ac/Power"
	}

	readonly property var _validSinglePhase: {
		let validPhase = null
		for (let i = 0; i < pvInverter.phases.count; ++i) {
			let p = pvInverter.phases.getPhase(i)
			if (p && p.isValid) {
				if (validPhase != null) {
					// multiple valid phases, cannot sum current/voltage
					return null
				} else {
					// have at least one valid phase.
					validPhase = p
				}
			}
		}
		return validPhase
	}

	onValidChanged: {
		if (!!Global.pvInverters) {
			if (valid) {
				Global.pvInverters.addInverter(pvInverter)
			} else {
				Global.pvInverters.removeInverter(pvInverter)
			}
		}
	}
}
