/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Instantiator {
	id: root

	property real totalPower: NaN
	property real totalCurrent: NaN
	property int maxPhaseCount: 0

	// AC power is the total power from Ac/PvOnGrid/L*/Power, Ac/PvOnGenset/L*/Power
	// and Ac/PvOnOutput/L*/Power.
	function updateAcTotals() {
		let _totalPower = NaN
		let _totalCurrent = NaN

		for (let i = 0; i < count; ++i) {
			const acPv = objectAt(i)
			if (!!acPv) {
				for (let j = 0; j < acPv.pvPhases.count; ++j) {
					const phase = acPv.pvPhases.objectAt(j)
					if (!phase) {
						continue
					}
					_totalPower = Units.sumRealNumbers(_totalPower, phase.power)
					_totalCurrent = Units.sumRealNumbers(_totalCurrent, phase.current)
				}
			}
		}
		root.totalPower = _totalPower
		root.totalCurrent = _totalCurrent
	}

	function _updateMaximumPhaseCount() {
		let _maxPhaseCount = 0
		for (let i = 0; i < count; ++i) {
			const acPvDelegate = root.objectAt(i)
			if (!!acPvDelegate) {
				_maxPhaseCount = Math.max(_maxPhaseCount, acPvDelegate.phaseCount)
			}
		}
		root.maxPhaseCount = _maxPhaseCount
	}

	model: [
		Global.system.serviceUid + "/Ac/PvOnGrid",
		Global.system.serviceUid + "/Ac/PvOnGenset",
		Global.system.serviceUid + "/Ac/PvOnOutput"
	]

	delegate: QtObject {
		id: acPvDelegate

		readonly property string serviceUid: modelData
		readonly property int phaseCount: vePhaseCount.value || 0

		readonly property VeQuickItem vePhaseCount: VeQuickItem {
			uid: acPvDelegate.serviceUid + "/NumberOfPhases"
			onValueChanged: {
				const phaseCount = value === undefined ? 0 : value
				if (pvPhases.count !== phaseCount) {
					pvPhases.model = phaseCount
					Qt.callLater(root._updateMaximumPhaseCount)
				}
			}
		}

		// Each Ac/PvOnX uid has 1-3 phases with power and current, e.g. Ac/PvOnGrid/L1/Power,
		// Ac/PvOnGrid/L1/Current
		property var pvPhases: Instantiator {
			model: null
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
}
