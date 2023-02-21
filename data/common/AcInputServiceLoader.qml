/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils


/*
  Provides frequency/current/power/voltage readings for an AC input, including each phase
  (if applicable). These come from the input-specific service, e.g. com.victronenergy.vebus,
  com.victronenergy.genset for generator inputs and com.victronenergy.grid.
*/
Loader {
	id: root

	property string serviceUid
	property string serviceType
	property bool valid

	property real frequency: valid ? _frequency : NaN
	property real current: valid ? _current : NaN
	property real power: valid ? _power : NaN
	property real voltage: valid ? _voltage : NaN
	readonly property ListModel phases: valid ? validPhases : invalidPhases

	property real _frequency: NaN
	property real _current: NaN
	property real _power: NaN
	property real _voltage: NaN

	function _resetModel(model, count) {
		model.clear()
		for (let i = 0; i < count; ++i) {
			model.append({ name: "L" + (i+1), frequency: NaN, current: NaN, power: NaN, voltage: NaN })
		}
	}

	function _setPhaseCount(phaseCount) {
		_resetModel(validPhases, phaseCount)
		_resetModel(invalidPhases, phaseCount)
		item.model = phaseCount
	}

	function _updateValue(instantiator, index, propertyName, value) {
		// update phase model value
		validPhases.setProperty(index, propertyName, value === undefined ? NaN : value)

		// update total value
		let total = 0
		let foundValidValue = false
		for (let i = 0; i < instantiator.count; ++i) {
			const obj = instantiator.objectAt(i)
			if (!obj) {
				continue
			}
			const veItemValue = obj["_" + propertyName]["value"]
			if (veItemValue !== undefined) {
				foundValidValue = true
			}
			total += veItemValue || 0
		}
		root["_" + propertyName] = foundValidValue ? total : NaN
	}

	sourceComponent: {
		if (serviceUid == "" || serviceType == "") {
			return null
		} else if (serviceType == "vebus") {
			return vebusComponent
		} else if (serviceType == "grid" || serviceType == "genset") {
			return gridOrGensetComponent
		} else {
			console.warn("Unsupported AC input service:", serviceType, "for uid:", serviceUid)
			return null
		}
	}

	onStatusChanged: {
		if (status === Loader.Error) {
			console.warn("Unable to load AC input service:", serviceUid)
		}
	}

	ListModel {
		id: validPhases
	}

	ListModel {
		id: invalidPhases
	}

	VeQuickItem {
		id: vebusPhaseCount

		uid: root.status === Loader.Ready && serviceType == "vebus"
			 ? root.serviceUid + "/Ac/NumberOfPhases"
			 : ""

		onValueChanged: {
			if (value !== undefined) {
				root._setPhaseCount(value)
			}
		}
	}

	DataPoint {
		id: gridOrGensetPhaseCount

		source: {
			if (root.status === Loader.Ready) {
				if (serviceType == "grid") {
					return "com.victronenergy.system/Ac/Grid/NumberOfPhases"
				} else if (serviceType == "genset") {
					return "com.victronenergy.system/Ac/Genset/NumberOfPhases"
				}
			}
			return ""
		}

		onValueChanged: {
			if (value !== undefined) {
				root._setPhaseCount(value)
			}
		}
	}

	Component {
		id: vebusComponent

		Instantiator {
			id: instantiator

			model: null

			delegate: QtObject {
				id: phase

				readonly property string phasePath: root.serviceUid + "/Ac/ActiveIn/L" + (index + 1)

				readonly property VeQuickItem _frequency: VeQuickItem {
					uid: phase.phasePath + "/F"
					onValueChanged: root._updateValue(instantiator, model.index, "frequency", value)
				}
				readonly property VeQuickItem _current: VeQuickItem {
					uid: phase.phasePath + "/I"
					onValueChanged: root._updateValue(instantiator, model.index, "current", value)
				}
				readonly property VeQuickItem _power: VeQuickItem {
					uid: phase.phasePath + "/P"
					onValueChanged: root._updateValue(instantiator, model.index, "power", value)
				}
				readonly property VeQuickItem _voltage: VeQuickItem {
					uid: phase.phasePath + "/V"
					onValueChanged: root._updateValue(instantiator, model.index, "voltage", value)
				}
			}
		}
	}

	// Paths are same for com.victronenergy.grid and com.victronenergy.genset, so this
	// component is used for both.
	Component {
		id: gridOrGensetComponent

		Instantiator {
			id: instantiator

			model: null

			delegate: QtObject {
				id: phase

				readonly property string phasePath: root.serviceUid + "/Ac/L" + (index + 1)

				readonly property VeQuickItem _frequency: VeQuickItem {
					uid: phase.phasePath + "/Frequency"
					onValueChanged: root._updateValue(instantiator, model.index, "frequency", value)
				}
				readonly property VeQuickItem _current: VeQuickItem {
					uid: phase.phasePath + "/Current"
					onValueChanged: root._updateValue(instantiator, model.index, "current", value)
				}
				readonly property VeQuickItem _power: VeQuickItem {
					uid: phase.phasePath + "/Power"
					onValueChanged: root._updateValue(instantiator, model.index, "power", value)
				}
				readonly property VeQuickItem _voltage: VeQuickItem {
					uid: phase.phasePath + "/Voltage"
					onValueChanged: root._updateValue(instantiator, model.index, "voltage", value)
				}
			}
		}
	}
}
