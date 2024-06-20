/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	readonly property bool _feedbackEnabled: Global.systemSettings.essFeedbackToGridEnabled

	property Instantiator _phaseObjects: Instantiator {
		model: null
		delegate: QtObject {
			readonly property VeQuickItem _current: VeQuickItem {
				uid:  Global.system.serviceUid + "/Ac/ActiveIn/L" + (model.index + 1) + "/Current"
				readonly property real currentValue: !isValid ? NaN : value
				readonly property real clampedCurrentValue: (root._feedbackEnabled || isNaN(currentValue)) ? currentValue
								: currentValue > 0 ? currentValue // see AcInputs.clampMeasurement()
								: 0.0
				onClampedCurrentValueChanged: {
					if (model.index >= 0 && model.index < root.count) {
						setProperty(model.index, "current", clampedCurrentValue)
					}
				}
			}

			readonly property VeQuickItem _power: VeQuickItem {
				uid: Global.system.serviceUid + "/Ac/ActiveIn/L" + (model.index + 1) + "/Power"
				readonly property real powerValue: !isValid ? NaN : value
				readonly property real clampedPowerValue: (root._feedbackEnabled || isNaN(powerValue)) ? powerValue
								: powerValue > 0 ? powerValue // see AcInputs.clampMeasurement().
								: 0.0
				onClampedPowerValueChanged: {
					if (model.index >= 0 && model.index < root.count) {
						setProperty(model.index, "power", clampedPowerValue)
					}
				}
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
