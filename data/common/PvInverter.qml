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
	readonly property real current: pvInverter.phases.singlePhaseCurrent
	readonly property real voltage: pvInverter.phases.singlePhaseVoltage

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
				id: phaseObject
				required property int index
				readonly property string phaseUid: pvInverter.serviceUid + "/Ac/L" + (index + 1)

				readonly property string name: "L" + (index + 1)
				readonly property real energy: _phaseEnergy.isValid ? _phaseEnergy.value : NaN
				readonly property real power: _phasePower.isValid ? _phasePower.value : NaN
				readonly property real current: _phaseCurrent.isValid ? _phaseCurrent.value : NaN
				readonly property real voltage: _phaseVoltage.isValid ? _phaseVoltage.value : NaN

				function _updatePhaseModel(valid, index, role) {
					if (valid) {
						pvInverter.phases.updateCount(index + 1)
					} else {
						pvInverter.phases.setValue(index, role, NaN)
					}
				}

				readonly property VeQuickItem _phaseEnergy: VeQuickItem {
					uid: phaseUid + "/Energy/Forward"
					onIsValidChanged: phaseObject._updatePhaseModel(isValid, phaseObject.index, PhaseModel.EnergyRole)
					onValueChanged: phases.setValue(index, PhaseModel.EnergyRole, value)
				}
				readonly property VeQuickItem _phasePower: VeQuickItem {
					uid: phaseUid + "/Power"
					onIsValidChanged: phaseObject._updatePhaseModel(isValid, phaseObject.index, PhaseModel.PowerRole)
					onValueChanged: phases.setValue(index, PhaseModel.PowerRole, value)
				}
				readonly property VeQuickItem _phaseCurrent: VeQuickItem {
					uid: phaseUid + "/Current"
					onIsValidChanged: phaseObject._updatePhaseModel(isValid, phaseObject.index, PhaseModel.CurrentRole)
					onValueChanged: phases.setValue(index, PhaseModel.CurrentRole, value)
				}
				readonly property VeQuickItem _phaseVoltage: VeQuickItem {
					uid: phaseUid + "/Voltage"
					onIsValidChanged: phaseObject._updatePhaseModel(isValid, phaseObject.index, PhaseModel.VoltageRole)
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
