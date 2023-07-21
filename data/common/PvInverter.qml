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
		function setPhaseProperty(index, propertyName, value) {
			if (index >= 0 && index < count) {
				setProperty(index, propertyName, value === undefined ? NaN : value)
			} else {
				console.warn("setPhaseProperty(): bad index", index, "count is", count)
			}
		}

		function setPhaseCount(phaseCount) {
			clear()
			for (let i = 0; i < phaseCount; ++i) {
				append({ name: "L" + (i + 1), energy: NaN, power: NaN, current: NaN, voltage: NaN })
			}
			_phaseObjects.model = phaseCount
		}

		readonly property Instantiator _phaseObjects: Instantiator {
			model: null
			delegate: QtObject {
				readonly property VeQuickItem _phaseEnergy: VeQuickItem {
					uid: pvInverter.serviceUid + "/Ac/L" + (model.index + 1) + "/Energy/Forward"
					onValueChanged: phases.setPhaseProperty(model.index, "energy", value)
				}
				readonly property VeQuickItem _phasePower: VeQuickItem {
					uid: pvInverter.serviceUid + "/Ac/L" + (model.index + 1) + "/Power"
					onValueChanged: phases.setPhaseProperty(model.index, "power", value)
				}
				readonly property VeQuickItem _phaseCurrent: VeQuickItem {
					uid: pvInverter.serviceUid + "/Ac/L" + (model.index + 1) + "/Current"
					onValueChanged: phases.setPhaseProperty(model.index, "current", value)
				}
				readonly property VeQuickItem _phaseVoltage: VeQuickItem {
					uid: pvInverter.serviceUid + "/Ac/L" + (model.index + 1) + "/Voltage"
					onValueChanged: phases.setPhaseProperty(model.index, "voltage", value)
				}
			}
		}

		readonly property VeQItemSortTableModel _phaseSources: VeQItemSortTableModel {
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "L[0-9]+"
			onRowCountChanged: phases.setPhaseCount(rowCount)

			model: VeQItemTableModel {
				uids: [pvInverter.serviceUid + "/Ac"]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
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

	property bool _valid: deviceInstance.value !== undefined
	on_ValidChanged: {
		if (_valid) {
			Global.pvInverters.addInverter(pvInverter)
		} else {
			Global.pvInverters.removeInverter(pvInverter)
		}
	}
}
