/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	property real totalPower
	property real firstPhaseCurrent: count === 1 ? get(0).current : NaN

	readonly property Timer _timer: Timer { // timer needed so the display doesn't update too frequently
		interval: 1000
		repeat: true
		running: true
		onTriggered: {
			let sum = 0
			for (let i = 0; i < root.count; ++i) {
				sum += root.get(i).power || 0
			}
			root.totalPower  = sum
		}
	}

	property Instantiator _phaseObjects: Instantiator {
		model: null
		delegate: QtObject {
			readonly property VeQuickItem _current: VeQuickItem {
				uid:  Global.system.serviceUid + "/Ac/ActiveIn/L" + (model.index + 1) + "/Current"
				onValueChanged: {
					if (model.index >= 0 && model.index < root.count) {
						setProperty(model.index, "current", isValid ? value : NaN)
					}
				}
			}

			readonly property VeQuickItem _power: VeQuickItem {
				uid: Global.system.serviceUid + "/Ac/ActiveIn/L" + (model.index + 1) + "/Power"
				onValueChanged: {
					if (model.index >= 0 && model.index < root.count) {
						setProperty(model.index, "power", isValid ? value : NaN)
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
