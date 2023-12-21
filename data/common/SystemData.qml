/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils
import Victron.Units

QtObject {
	id: root

	readonly property DataPoint systemState: DataPoint {
		source: Global.system.serviceUid + "/SystemState/State"
		Component.onCompleted: {
			Global.system.state = Qt.binding(function() { return value || VenusOS.System_State_Off })
		}
	}

	//--- AC data ---

	readonly property DataPoint consumptionPhaseCount: DataPoint {
		function _update() {
			if (!!Global.system) {
				Global.system.ac.consumption.setPhaseCount(value)
			}
			consumptionInputObjects.model = value
			consumptionOutputObjects.model = value
		}
		source: Global.system.serviceUid + "/Ac/Consumption/NumberOfPhases"
		Component.onCompleted: _update()
		onValueChanged: _update()
	}

	property Instantiator consumptionInputObjects: Instantiator {
		model: null
		delegate: QtObject {
			id: consumptionInput

			property real power: NaN
			property real current: NaN

			readonly property DataPoint vePower: DataPoint {
				function _update() {
					consumptionInput.power = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel)
				}
				source: Global.system.serviceUid + "/Ac/ConsumptionOnInput/L" + (model.index + 1) + "/Power"
				Component.onCompleted: _update()
				onValueChanged: _update()
			}
			// TODO this path doesn't exist in dbus yet but should be provided at a later stage.
			// Verify when it is added.
			readonly property DataPoint veCurrent: DataPoint {
				function _update() {
					consumptionInput.current = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel)
				}
				source: Global.system.serviceUid + "/Ac/ConsumptionOnInput/L" + (model.index + 1) + "/Current"
				Component.onCompleted: _update()
				onValueChanged: _update()
			}
		}
	}

	property Instantiator consumptionOutputObjects: Instantiator {
		model: null
		delegate: QtObject {
			id: consumptionOutput

			property real power: NaN
			property real current: NaN

			readonly property DataPoint vePower: DataPoint {
				function _update() {
					consumptionOutput.power = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel)
				}
				source: Global.system.serviceUid + "/Ac/ConsumptionOnOutput/L" + (model.index + 1) + "/Power"
				Component.onCompleted: _update()
				onValueChanged: _update()
			}
			readonly property DataPoint veCurrent: DataPoint {
				function _update() {
					consumptionOutput.current = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel)
				}
				source: Global.system.serviceUid + "/Ac/ConsumptionOnOutput/L" + (model.index + 1) + "/Current"
				Component.onCompleted: _update()
				onValueChanged: _update()
			}
		}
	}

	function _updateConsumptionModel() {
		if (!!Global.system) {
			for (let i = 0; i < consumptionInputObjects.count; ++i) {
				const inputConsumption = consumptionInputObjects.objectAt(i)
				const inputPower = inputConsumption ? inputConsumption.power : NaN
				const inputCurrent = inputConsumption ? inputConsumption.current : NaN

				const outputConsumption = consumptionOutputObjects.objectAt(i)
				const outputPower = outputConsumption ? outputConsumption.power : NaN
				const outputCurrent = outputConsumption ? outputConsumption.current : NaN

				Global.system.ac.consumption.setPhaseData(i, {
					power: Units.sumRealNumbers(inputPower, outputPower),
					current: Units.sumRealNumbers(inputCurrent, outputCurrent)
				})
			}
		}
	}

	//--- DC data ---

	readonly property DataPoint veSystemPower: DataPoint {
		source: Global.system.serviceUid + "/Dc/System/Power"
		Component.onCompleted: {
			Global.system.dc.power = Qt.binding(function() { return value === undefined ? NaN : value })
		}
	}

	readonly property DataPoint veBatteryVoltage: DataPoint {
		source: Global.system.serviceUid + "/Dc/Battery/Voltage"
		Component.onCompleted: {
			Global.system.dc.voltage = Qt.binding(function() { return value === undefined ? NaN : value })
		}
	}
}
