/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var veSystem

	property VeQuickItem systemState: VeQuickItem {
		function _update() {
			Global.system.state = value || VenusOS.System_State_Off
		}
		uid: "mqtt/system/0/SystemState/State"
		Component.onCompleted: _update()
		onValueChanged: _update()
	}

	//--- AC data ---

	property VeQuickItem consumptionPhaseCount: VeQuickItem {
		function _update() {
			Global.system.ac.consumption.setPhaseCount(value)
			consumptionInputObjects.model = value
			consumptionOutputObjects.model = value
		}
		uid: "mqtt/system/0/Ac/Consumption/NumberOfPhases"
		Component.onCompleted: _update()
		onValueChanged: _update()
	}

	property Instantiator consumptionInputObjects: Instantiator {
		model: null
		delegate: QtObject {
			id: consumptionInput

			property real power: NaN
			property real current: NaN

			property VeQuickItem vePower: VeQuickItem {
				function _update() {
					consumptionInput.power = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel)
				}
				uid: "mqtt/system/0/Ac/ConsumptionOnInput/L" + (model.index + 1) + "/Power"
				Component.onCompleted: _update()
				onValueChanged: _update()
			}
			// TODO this path doesn't exist in dbus yet but should be provided at a later stage.
			// Verify when it is added.
			property VeQuickItem veCurrent: VeQuickItem {
				function _update() {
					consumptionInput.current = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel)
				}
				uid: "mqtt/system/0/Ac/ConsumptionOnInput/L" + (model.index + 1) + "/Current"
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

			property VeQuickItem vePower: VeQuickItem {
				function _update() {
					consumptionOutput.power = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel)
				}
				uid: "mqtt/system/0/Ac/ConsumptionOnOutput/L" + (model.index + 1) + "/Power"
				Component.onCompleted: _update()
				onValueChanged: _update()
			}
			property VeQuickItem veCurrent: VeQuickItem {
				function _update() {
					consumptionOutput.current = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel)
				}
				uid: "mqtt/system/0/Ac/ConsumptionOnOutput/L" + (model.index + 1) + "/Current"
				Component.onCompleted: _update()
				onValueChanged: _update()
			}
		}
	}

	function _updateConsumptionModel() {
		for (let i = 0; i < consumptionInputObjects.count; ++i) {
			const inputConsumption = consumptionInputObjects.objectAt(i)
			const inputPower = inputConsumption ? inputConsumption.power : NaN
			const inputCurrent = inputConsumption ? inputConsumption.current : NaN

			const outputConsumption = consumptionOutputObjects.objectAt(i)
			const outputPower = outputConsumption ? outputConsumption.power : NaN
			const outputCurrent = outputConsumption ? outputConsumption.current : NaN

			Global.system.ac.consumption.setPhaseData(i, {
				power: Utils.sumRealNumbers(inputPower, outputPower),
				current: Utils.sumRealNumbers(inputCurrent, outputCurrent)
			})
		}
	}

	//--- DC data ---

	property VeQuickItem veSystemPower: VeQuickItem {
		function _update() {
			Global.system.dc.power = value === undefined ? NaN : value
		}
		uid: "mqtt/system/0/Dc/System/Power"
		Component.onCompleted: _update()
		onValueChanged: _update()
	}

	property VeQuickItem veBatteryVoltage: VeQuickItem {
		function _update() {
			Global.system.dc.voltage = value === undefined ? NaN : value
		}
		uid: "mqtt/system/0/Dc/Battery/Voltage"
		Component.onCompleted: _update()
		onValueChanged: _update()
	}
}
