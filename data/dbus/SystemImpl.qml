/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var veSystem

	property VeQuickItem systemState: VeQuickItem {
		uid: "dbus/com.victronenergy.systemSystemState/State"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: Global.system.state = value || VenusOS.System_State_Off
	}

	//--- AC data ---

	property VeQuickItem consumptionPhaseCount: VeQuickItem {
		uid: "dbus/com.victronenergy.system/Ac/Consumption/NumberOfPhases"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: {
			if (value !== undefined) {
				Global.system.ac.consumption.setPhaseCount(value)
				consumptionInputObjects.model = value
				consumptionOutputObjects.model = value
			}
		}
	}

	property Instantiator consumptionInputObjects: Instantiator {
		model: null
		delegate: QtObject {
			id: consumptionInput

			property real power: NaN
			property real current: NaN

			property VeQuickItem vePower: VeQuickItem {
				uid: "dbus/com.victronenergy.system/Ac/ConsumptionOnInput/L" + (model.index + 1) + "/Power"

				Component.onCompleted: valueChanged(this, value)
				onValueChanged: {
					consumptionInput.power = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel)
				}
			}
			// TODO this path doesn't exist in dbus yet but should be provided at a later stage.
			// Verify when it is added.
			property VeQuickItem veCurrent: VeQuickItem {
				uid: "dbus/com.victronenergy.system/Ac/ConsumptionOnInput/L" + (model.index + 1) + "/Current"

				Component.onCompleted: valueChanged(this, value)
				onValueChanged: {
					consumptionInput.current = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel)
				}
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
				uid: "dbus/com.victronenergy.system/Ac/ConsumptionOnOutput/L" + (model.index + 1) + "/Power"

				Component.onCompleted: valueChanged(this, value)
				onValueChanged: {
					consumptionOutput.power = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel)
				}
			}
			property VeQuickItem veCurrent: VeQuickItem {
				uid: "dbus/com.victronenergy.system/Ac/ConsumptionOnOutput/L" + (model.index + 1) + "/Current"

				Component.onCompleted: valueChanged(this, value)
				onValueChanged: {
					consumptionOutput.current = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel)
				}
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
		uid: "dbus/com.victronenergy.system/Dc/System/Power"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: Global.system.dc.power = value === undefined ? NaN : value
	}

	property VeQuickItem veBatteryVoltage: VeQuickItem {
		uid: "dbus/com.victronenergy.system/Dc/Battery/Voltage"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: Global.system.dc.voltage = value === undefined ? NaN : value
	}
}
