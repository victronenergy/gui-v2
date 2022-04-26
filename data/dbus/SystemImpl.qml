/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib

QtObject {
	id: root

	property var veDBus
	property var veSystem

	property VeQuickItem systemState: VeQuickItem {
		uid: veSystem.childUId("SystemState/State")
		onValueChanged: Global.system.state = value || VenusOS.System_State_Off
	}

	//--- AC data ---

	property VeQuickItem inputConsumptionPhaseCount: VeQuickItem {
		uid: veSystem.childUId("/Ac/ConsumptionOnInput/NumberOfPhases")
		onValueChanged: {
			if (value !== undefined) {
				Global.system.ac.consumption.resetPhases(value)
				consumptionInputObjects.model = value
			}
		}
	}

	property Instantiator consumptionInputObjects: Instantiator {
		model: null
		delegate: VeQuickItem {
			uid: veDBus.childUId("/Ac/ConsumptionOnInput/L" + (index + 1) + "/Power")

			onValueChanged: {
				const inputPower = value === undefined ? 0 : value
				const outputPower = Global.system.ac.consumption.phases.get(model.index).outputPower
				const combinedPower = inputPower + outputPower
				Global.system.ac.consumption.setPhaseData(model.index,
						{ "inputPower": inputPower, "power": combinedPower })
			}
		}
	}

	property VeQuickItem outputConsumptionPhaseCount: VeQuickItem {
		uid: veSystem.childUId("/Ac/ConsumptionOnOutput/NumberOfPhases")
		onValueChanged: {
			if (value !== undefined) {
				Global.system.ac.consumption.resetPhases(value)
				consumptionOutputObjects.model = value
			}
		}
	}

	property Instantiator consumptionOutputObjects: Instantiator {
		model: null
		delegate: VeQuickItem {
			uid: veDBus.childUId("/Ac/ConsumptionOnOutput/L" + (index + 1) + "/Power")

			onValueChanged: {
				const inputPower = Global.system.ac.consumption.phases.get(model.index).inputPower
				const outputPower = value === undefined ? 0 : value
				const combinedPower = inputPower + outputPower
				Global.system.ac.consumption.setPhaseData(model.index,
						{ "outputPower": outputPower, "power": combinedPower })
			}
		}
	}

	property VeQuickItem gensetPhaseCount: VeQuickItem {
		uid: veSystem.childUId("/Ac/Genset/NumberOfPhases")
		onValueChanged: {
			if (value !== undefined) {
				Global.system.ac.genset.resetPhases(value)
				gensetObjects.model = value
			}
		}
	}

	property Instantiator gensetObjects: Instantiator {
		model: null
		delegate: VeQuickItem {
			uid: veDBus.childUId("/Ac/Genset/L" + (index + 1) + "/Power")

			onValueChanged: {
				const power = value === undefined ? 0 : value
				Global.system.ac.genset.setPhaseData(model.index, { "power": power })
			}
		}
	}

	//--- DC data ---

	property VeQuickItem veSystemPower: VeQuickItem {
		uid: veSystem.childUId("/Dc/System/Power")
		onValueChanged: Global.system.dc.power = value === undefined ? NaN : value
	}
}
