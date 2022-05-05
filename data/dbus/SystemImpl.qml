/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var veDBus
	property var veSystem

	property VeQuickItem systemState: VeQuickItem {
		uid: veSystem.childUId("SystemState/State")
		onValueChanged: Global.system.state = value || VenusOS.System_State_Off
	}

	//--- AC data ---

	property VeQuickItem consumptionPhaseCount: VeQuickItem {
		uid: veSystem.childUId("/Ac/Consumption/NumberOfPhases")
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
				uid: veDBus.childUId("/Ac/ConsumptionOnInput/L" + (model.index + 1) + "/Power")
				onValueChanged: {
					consumptionInput.power = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel, model.index)
				}
			}
			// TODO this path doesn't exist in dbus yet but should be provided at a later stage.
			// Verify when it is added.
			property VeQuickItem veCurrent: VeQuickItem {
				uid: veDBus.childUId("/Ac/ConsumptionOnInput/L" + (model.index + 1) + "/Current")
				onValueChanged: {
					consumptionInput.current = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel, model.index)
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
				uid: veDBus.childUId("/Ac/ConsumptionOnOutput/L" + (model.index + 1) + "/Power")
				onValueChanged: {
					consumptionOutput.power = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel, model.index)
				}
			}
			property VeQuickItem veCurrent: VeQuickItem {
				uid: veDBus.childUId("/Ac/ConsumptionOnOutput/L" + (model.index + 1) + "/Current")
				onValueChanged: {
					consumptionOutput.current = value === undefined ? NaN : value
					Qt.callLater(root._updateConsumptionModel, model.index)
				}
			}
		}
	}

	function _updateConsumptionModel(index) {
		const inputConsumption = consumptionInputObjects.objectAt(index)
		const inputPower = inputConsumption ? inputConsumption.power : NaN
		const inputCurrent = inputConsumption ? inputConsumption.current : NaN

		const outputConsumption = consumptionOutputObjects.objectAt(index)
		const outputPower = outputConsumption ? outputConsumption.power : NaN
		const outputCurrent = outputConsumption ? outputConsumption.current : NaN

		Global.system.ac.consumption.setPhaseData(index, {
			power: Utils.sumRealNumbers(inputPower, outputPower),
			current: Utils.sumRealNumbers(inputCurrent, outputCurrent)
		})
	}

	//--- DC data ---

	property VeQuickItem veSystemPower: VeQuickItem {
		uid: veSystem.childUId("/Dc/System/Power")
		onValueChanged: Global.system.dc.power = value === undefined ? NaN : value
	}

	property VeQuickItem veBatteryVoltage: VeQuickItem {
		uid: veSystem.childUId("/Dc/Battery/Voltage")
		onValueChanged: Global.system.dc.voltage = value === undefined ? NaN : value
	}
}
