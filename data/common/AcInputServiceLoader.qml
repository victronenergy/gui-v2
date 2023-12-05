/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils
import Victron.Units

/*
  Provides measurements for an AC input, including each phase (if applicable).

  These come from the input-specific service, e.g. com.victronenergy.vebus,
  com.victronenergy.genset for generator inputs and com.victronenergy.grid.
*/
Loader {
	id: root

	property string serviceUid
	property string serviceType
	property bool valid

	readonly property real current: phases.count === 1 ? _firstPhaseCurrent : NaN // multi-phase systems don't have a total current
	property real currentLimit: item ? item.currentLimit : NaN
	property real power: valid && item ? item.power : NaN
	readonly property ListModel phases: valid ? validPhases : invalidPhases

	property real _firstPhaseCurrent: NaN

	function _resetModel(model, count) {
		model.clear()
		_firstPhaseCurrent = NaN
		for (let i = 0; i < count; ++i) {
			model.append({ name: "L" + (i+1), current: NaN, power: NaN })
		}
	}

	function _updatePhaseValue(phaseIndex, propertyName, propertyValue) {
		if (phaseIndex < 0) {
			return
		}
		validPhases.setProperty(phaseIndex, propertyName, propertyValue === undefined ? NaN : propertyValue)
		if (phaseIndex === 0 && propertyName === "current") {
			_firstPhaseCurrent = propertyValue
		}
	}

	function _setPhaseCount(phaseCount) {
		_resetModel(validPhases, phaseCount)
		_resetModel(invalidPhases, phaseCount)
		item.model = phaseCount
	}

	sourceComponent: {
		if (serviceUid == "" || serviceType == "") {
			return null
		} else if (serviceType == "vebus") {
			return vebusComponent
		} else if (serviceType == "multi") {
			return multiComponent
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

	DataPoint {
		source: {
			if (root.status === Loader.Ready) {
				if (serviceType == "vebus" || serviceType == "multi") {
					return root.serviceUid + "/Ac/NumberOfPhases"
				} else if (serviceType == "grid") {
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
			id: phaseObjects

			readonly property real power: _power.value === undefined ? NaN : _power.value
			readonly property real currentLimit: _currentLimit.value === undefined ? NaN : _currentLimit.value

			readonly property VeQuickItem _power: VeQuickItem {
				uid: root.serviceUid + "/Ac/ActiveIn/P"
			}

			readonly property VeQuickItem _activeInput: VeQuickItem {
				uid: root.serviceUid + "/Ac/ActiveIn/ActiveInput"
			}
			// Current limit for each AC input: /Ac/In/<1+>/CurrentLimit
			readonly property VeQuickItem _currentLimit: VeQuickItem {
				uid: _activeInput.value === undefined ? ""
				   : root.serviceUid + "/Ac/In/" + (_activeInput.value + 1) + "/CurrentLimit"
			}

			model: null

			delegate: AcPhase {
				id: phase

				// Phase paths for vebus:
				//      dbus/com.victronenergy.vebus.*/Ac/ActiveIn/L<1-3>
				//      mqtt/vebus/<instance>/Ac/ActiveIn/L<1-3>
				readonly property string phasePath: root.serviceUid + "/Ac/ActiveIn/L" + (index + 1)

				serviceUid: !!phase.phasePath ? phase.phasePath : ""
				onCurrentChanged: root._updatePhaseValue(model.index, "current", current)
				onPowerChanged: root._updatePhaseValue(model.index, "power", power)
			}
		}
	}


	Component {
		id: multiComponent

		Instantiator {
			id: phaseObjects

			property real power: NaN
			readonly property real currentLimit: _currentLimit.value === undefined ? NaN : _currentLimit.value

			readonly property VeQuickItem _activeInput: VeQuickItem {
				uid: root.serviceUid + "/Ac/ActiveIn/ActiveInput"
			}
			readonly property VeQuickItem _currentLimit: VeQuickItem {
				uid: _activeInput.value === undefined ? ""
				   : root.serviceUid + "/Ac/In/" + (_activeInput.value + 1) + "/CurrentLimit"
			}

			function _updateTotalPower() {
				let totalPower = NaN
				for (let i = 0; i < count; ++i) {
					const phaseObject = objectAt(i)
					if (phaseObject) {
						totalPower = Units.sumRealNumbers(totalPower, phaseObject.power)
					}
				}
				power = totalPower
			}

			model: null

			delegate: AcPhase {
				id: phase

				// Phase paths for multi (only need to monitor one input, i.e. the current actively one):
				//      dbus/com.victronenergy.multi.*/Ac/In/<1+>/L<1-3>
				//      mqtt/vebus/<instance>/Ac/In/<1+>/L<1-3>
				readonly property string phasePath: _activeInput.value === undefined ? ""
						: (root.serviceUid + "/Ac/In/" + (_activeInput.value + 1) + "/L" + (index + 1))

				serviceUid: !!phase.phasePath ? phase.phasePath : ""
				onCurrentChanged: root._updatePhaseValue(model.index, "current", current)
				onPowerChanged: {
					root._updatePhaseValue(model.index, "power", power)
					Qt.callLater(phaseObjects._updateTotalPower)
				}
			}
		}
	}

	// Paths are same for com.victronenergy.grid and com.victronenergy.genset, so this
	// component is used for both.
	Component {
		id: gridOrGensetComponent

		Instantiator {
			id: phaseObjects

			readonly property real power: _power.value === undefined ? NaN : _power.value

			// For these devices, there is no current limit.
			readonly property real currentLimit: NaN

			readonly property VeQuickItem _power: VeQuickItem {
				uid: root.serviceUid + "/Ac/Power"
			}

			model: null

			delegate: QtObject {
				id: phase

				readonly property string phasePath: root.serviceUid + "/Ac/L" + (index + 1)

				readonly property VeQuickItem _current: VeQuickItem {
					uid: phase.phasePath + "/Current"
					onValueChanged: root._updatePhaseValue(model.index, "current", value)
				}
				readonly property VeQuickItem _power: VeQuickItem {
					uid: phase.phasePath + "/Power"
					onValueChanged: root._updatePhaseValue(model.index, "power", value)
				}
			}
		}
	}
}
