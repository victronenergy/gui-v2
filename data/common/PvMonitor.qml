/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Instantiator {
	id: root

	// --- AC values ---

	// AC power is the total power from Ac/PvOnGrid/L*/Power, Ac/PvOnGenset/L*/Power
	// and Ac/PvOnOutput/L*/Power.
	function updateAcTotals() {
		let totalPower = NaN
		let totalCurrent = NaN

		for (let i = 0; i < count; ++i) {
			const acPv = objectAt(i)
			if (!!acPv) {
				for (let j = 0; j < acPv.pvPhases.count; ++j) {
					const phase = acPv.pvPhases.objectAt(j)
					if (!phase) {
						continue
					}
					if (!isNaN(phase.power)) {
						if (isNaN(totalPower)) {
							totalPower = 0
						}
						totalPower += phase.power
					}
					if (!isNaN(phase.current)) {
						if (isNaN(totalCurrent)) {
							totalCurrent = 0
						}
						totalCurrent += phase.current
					}
				}
			}
		}
		if (!!Global.system) {
			Global.system.solar.acPower = totalPower
			Global.system.solar.acCurrent = totalCurrent
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

				property real power
				property real current

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

	readonly property DataPoint veDcPower: DataPoint {
		source: "com.victronenergy.system/Dc/Pv/Power"
		onValueChanged: if (!!Global.system) Global.system.solar.dcPower = value === undefined ? NaN : value
	}

	readonly property DataPoint veDcCurrent: DataPoint {
		source: "com.victronenergy.system/Dc/Pv/Current"
		onValueChanged: if (!!Global.system) Global.system.solar.dcCurrent = value === undefined ? NaN : value
	}
}
