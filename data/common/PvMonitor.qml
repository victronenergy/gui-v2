/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Instantiator {
	id: root

	// --- AC values ---

	// AC power is the total power from Ac/PvOnGrid, Ac/PvOnGenset and Ac/PvOnOutput.
	function updateAcTotals() {
		let totalPower = NaN
		let totalCurrent = NaN

		for (let i = 0; i < count; ++i) {
			const acPv = objectAt(i)
			if (!!acPv) {
				for (let j = 0; j < acPv.pvPhases.count; ++j) {
					const phase = acPv.pvPhases.objectAt(j)
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
		Global.solarChargers.acPower = totalPower
		Global.solarChargers.acCurrent = totalCurrent
	}

	delegate: QtObject {
		id: acPvDelegate

		readonly property string serviceUid: modelData

		readonly property DataPoint vePhaseCount: DataPoint {
			source: acPvDelegate.serviceUid + "/NumberOfPhases"
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

				readonly property DataPoint vePower: DataPoint {
					source: acPvDelegate.serviceUid + "/L" + (model.index + 1) + "/Power"
					onValueChanged: {
						phase.power = value === undefined ? NaN : value
						Qt.callLater(root.updateAcTotals)
					}
				}
				readonly property DataPoint veCurrent: DataPoint {
					source: acPvDelegate.serviceUid + "/L" + (model.index + 1) + "/Current"
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
		onValueChanged: Global.solarChargers.dcPower = value === undefined ? NaN : value
	}

	readonly property DataPoint veDcCurrent: DataPoint {
		source: "com.victronenergy.system/Dc/Pv/Current"
		onValueChanged: Global.solarChargers.dcCurrent = value === undefined ? NaN : value
	}
}
