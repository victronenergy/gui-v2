/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils
import Victron.Units
import Victron.Veutil

Instantiator {
	id: root

	property int acSourceCount
	property real acCurrent: NaN

	function updateOverallCurrent() {
		if (!Global.system) {
			return
		}
		// Current values cannot be summed, so if there is more than one current measurement from
		// AC and DC sources combined, set the overall current to NaN.
		const totalSourceCount = acSourceCount + (veDcCurrent.value === undefined ? 0 : 1)
		if (totalSourceCount === 1) {
			Global.system.solar.current = acSourceCount === 1 ? acCurrent : veDcCurrent.value
		} else {
			Global.system.solar.current = NaN
		}
	}

	// --- AC values ---

	// AC power is the total power from Ac/PvOnGrid/L*/Power, Ac/PvOnGenset/L*/Power
	// and Ac/PvOnOutput/L*/Power.
	function updateAcTotals() {
		let totalPower = NaN
		let totalPhaseCount = 0
		let lastPhaseObject = null

		for (let i = 0; i < count; ++i) {
			const acPv = objectAt(i)
			if (!!acPv) {
				for (let j = 0; j < acPv.pvPhases.count; ++j) {
					const phase = acPv.pvPhases.objectAt(j)
					if (!phase) {
						continue
					}
					totalPower = Units.sumRealNumbers(totalPower, phase.power)
					lastPhaseObject = phase
					totalPhaseCount++
				}
			}
		}
		acSourceCount = totalPhaseCount

		// Current values cannot be summed, so if there is more than one current measurement
		// found in any AC PV source, set acCurrent=NaN.
		acCurrent = totalPhaseCount === 1 ? lastPhaseObject.current : NaN

		if (!!Global.system) {
			Global.system.solar.acPower = totalPower
			updateOverallCurrent()
		}
	}

	delegate: QtObject {
		id: acPvDelegate

		readonly property string serviceUid: modelData

		readonly property VeQuickItem vePhaseCount: VeQuickItem {
			uid: acPvDelegate.serviceUid + "/NumberOfPhases"
			onValueChanged: {
				const phaseCount = value === undefined ? 0 : value
				if (pvPhases.count !== phaseCount) {
					pvPhases.model = phaseCount
				}
			}
		}

		// Each Ac/PvOnX uid has 1-3 phases with power and current, e.g. Ac/PvOnGrid/L1/Power,
		// Ac/PvOnGrid/L1/Current
		property var pvPhases: Instantiator {
			delegate: QtObject {
				id: phase

				property real power: NaN
				property real current: NaN

				readonly property VeQuickItem vePower: VeQuickItem {
					uid: acPvDelegate.serviceUid + "/L" + (model.index + 1) + "/Power"
					onValueChanged: {
						phase.power = value === undefined ? NaN : value
						Qt.callLater(root.updateAcTotals)
					}
				}
				readonly property VeQuickItem veCurrent: VeQuickItem {
					uid: acPvDelegate.serviceUid + "/L" + (model.index + 1) + "/Current"
					onValueChanged: {
						phase.current = value === undefined ? NaN : value
						Qt.callLater(root.updateAcTotals)
					}
				}
			}
		}
	}


	// --- DC values ---

	readonly property VeQuickItem veDcPower: VeQuickItem {
		uid: Global.system.serviceUid + "/Dc/Pv/Power"
		onValueChanged: if (!!Global.system) Global.system.solar.dcPower = value === undefined ? NaN : value
	}

	readonly property VeQuickItem veDcCurrent: VeQuickItem {
		uid: Global.system.serviceUid + "/Dc/Pv/Current"
		onValueChanged: root.updateOverallCurrent()
	}
}
