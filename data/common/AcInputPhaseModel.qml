/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	signal phaseValueChanged(int phaseIndex, string propertyName, real propertyValue)

	function _updatePhaseValue(phaseIndex, propertyName, propertyValue) {
		if (phaseIndex < 0 || phaseIndex >= count) {
			return
		}

		const v = propertyValue === undefined ? NaN
				: (Global.acInputs ? Global.acInputs.clampMeasurement(propertyValue) : propertyValue)

		setProperty(phaseIndex, propertyName, v)
		phaseValueChanged(phaseIndex, propertyName, v)
	}

	property Instantiator _phaseObjects: Instantiator {
		model: null
		delegate: QtObject {
			readonly property VeQuickItem _current: VeQuickItem {
				uid:  Global.system.serviceUid + "/Ac/ActiveIn/L" + (model.index + 1) + "/Current"
				onValueChanged: root._updatePhaseValue(model.index, "current", value)
			}

			readonly property VeQuickItem _power: VeQuickItem {
				uid: Global.system.serviceUid + "/Ac/ActiveIn/L" + (model.index + 1) + "/Power"
				onValueChanged: root._updatePhaseValue(model.index, "power", value)
			}
		}
	}

	readonly property VeQuickItem _numberOfPhases: VeQuickItem {
		uid: Global.system.serviceUid + "/Ac/ActiveIn/NumberOfPhases"
		onValueChanged: {
			const count = value || 0
			root._phaseObjects.model = null
			root.clear()
			for (let i = 0; i < count; ++i) {
				root.append({ name: "L" + (i+1), current: NaN, power: NaN })
			}
			root._phaseObjects.model = count
		}
	}
}
