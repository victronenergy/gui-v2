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
	readonly property real current: _current.isValid ? _current.value : NaN
	readonly property real power: _power.isValid ? _power.value : NaN
	readonly property real voltage: _voltage.isValid ? _voltage.value : NaN

	readonly property QtObject phases: QtObject {
		property int count

		function updateCount(maxPhaseCount) {
			count = Math.max(count, maxPhaseCount)
		}

		function get(index) {
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

				readonly property VeQuickItem _phaseEnergy: VeQuickItem {
					uid: phaseUid + "/Energy/Forward"
					onIsValidChanged: if (isValid) phases.updateCount(index + 1)
				}
				readonly property VeQuickItem _phasePower: VeQuickItem {
					uid: phaseUid + "/Power"
					onIsValidChanged: if (isValid) phases.updateCount(index + 1)
				}
				readonly property VeQuickItem _phaseCurrent: VeQuickItem {
					uid: phaseUid + "/Current"
					onIsValidChanged: if (isValid) phases.updateCount(index + 1)
				}
				readonly property VeQuickItem _phaseVoltage: VeQuickItem {
					uid: phaseUid + "/Voltage"
					onIsValidChanged: if (isValid) phases.updateCount(index + 1)
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

	readonly property VeQuickItem _current: VeQuickItem {
		uid: pvInverter.serviceUid + "/Ac/Current"
	}

	readonly property VeQuickItem _voltage: VeQuickItem {
		uid: pvInverter.serviceUid + "/Ac/Voltage"
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
