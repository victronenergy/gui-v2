/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Device {
	id: pvInverter

	readonly property int statusCode: _statusCode.value === undefined ? -1 : _statusCode.value
	readonly property int errorCode: _errorCode.value === undefined ? -1 : _errorCode.value

	readonly property real energy: _energy.value === undefined ? NaN : _energy.value
	readonly property real power: _power.value === undefined ? NaN : _power.value
	readonly property real current: _current.value === undefined ? NaN : _current.value
	readonly property real voltage: _voltage.value === undefined ? NaN : _voltage.value

	readonly property ListModel phases: ListModel {
		function setPhaseProperty(phaseName, propertyName, value) {
			let index = count
			let needsInsert = true
			for (let i = 0; i < count; ++i) {
				const currName = get(i).name
				if (currName === phaseName) {
					needsInsert = false
					index = i
					break
				} else if (currName > phaseName) {
					// Do an ordered insertion.
					index = i
					break
				}
			}
			if (value === undefined) {
				value = NaN
			}
			if (needsInsert) {
				if (isNaN(value)) {
					// Wait until we have a valid value for this phase before adding it to the model
					return
				}
				let data = { name: phaseName, energy: NaN, power: NaN, current: NaN, voltage: NaN }
				data[propertyName] = value
				insert(index, data)
			} else if (index >= 0 && index < count) {
				setProperty(index, propertyName, value)
			} else {
				console.warn("setPhaseProperty(): bad index", index, "count is", count)
			}
		}

		readonly property Instantiator _phaseObjects: Instantiator {
			model: 3
			delegate: QtObject {
				readonly property string phaseName: "L" + (model.index + 1)
				readonly property string phaseUid: pvInverter.serviceUid + "/Ac/" + phaseName

				readonly property VeQuickItem _phaseEnergy: VeQuickItem {
					uid: phaseUid + "/Energy/Forward"
					onValueChanged: phases.setPhaseProperty(phaseName, "energy", value)
				}
				readonly property VeQuickItem _phasePower: VeQuickItem {
					uid: phaseUid + "/Power"
					onValueChanged: phases.setPhaseProperty(phaseName, "power", value)
				}
				readonly property VeQuickItem _phaseCurrent: VeQuickItem {
					uid: phaseUid + "/Current"
					onValueChanged: phases.setPhaseProperty(phaseName, "current", value)
				}
				readonly property VeQuickItem _phaseVoltage: VeQuickItem {
					uid: phaseUid + "/Voltage"
					onValueChanged: phases.setPhaseProperty(phaseName, "voltage", value)
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
