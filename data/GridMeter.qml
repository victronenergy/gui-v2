/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: {
			for (let i = 0; i < 3; ++i) {
				append({ name: "L" + (i+1), power: NaN })
			}
		}
	}

	property real power

	VeQuickItem {
		uid: veSystem.childUId("/Ac/Grid/NumberOfPhases")
		onValueChanged: {
			if (value !== undefined) {
				gridObjects.model = value
			}
		}
	}

	Instantiator {
		id: gridObjects

		model: null

		delegate: VeQuickItem {
			readonly property string phaseId: "L" + (index + 1)
			property real power

			// TODO use com.victronenergy.grid instead when available. For now, use system API
			// as it works with data simulations.
			uid: veSystem.childUId("/Ac/Grid/" + phaseId + "/Power")

			onValueChanged: {
				power = value == undefined ? NaN : value
				root.model.setProperty(model.index, "power", power)

				let total = 0
				for (let i = 0; i < gridObjects.count; ++i) {
					total += gridObjects.objectAt(i).power || 0
				}
				root.power = total
				Utils.updateMaximumValue("grid.power", root.power)
			}
		}
	}
}
