/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property QtObject consumption: QtObject {
		property real power: NaN
		readonly property real current: phases.count === 1 ? _firstPhaseCurrent : NaN // multi-phase systems don't have a total current
		readonly property real maximumCurrent: _maximumCurrent.value === undefined ? NaN : _maximumCurrent.value
		property real _firstPhaseCurrent: NaN
		readonly property bool l2AndL1OutSummed: !!_l2L1OutSummed.value
		onL2AndL1OutSummedChanged: setPhaseCount(phases.count)
		readonly property VeQuickItem _l2L1OutSummed: VeQuickItem {
			uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Ac/State/SplitPhaseL2L1OutSummed" : ""
		}

		property ListModel phases: ListModel {}

		function setPhaseCount(phaseCount) {
			reset()

			if (l2AndL1OutSummed) {
				phases.append({
					name: "L1 + L2",
					power: NaN,
					current: NaN
				})
				return
			}

			for (let i = 0; i < phaseCount; ++i) {
				phases.append({
					name: "L" + (i + 1),
					power: NaN,
					current: NaN
				})
			}
		}

		function setPhaseData(index, data) {
			if (l2AndL1OutSummed && index > 0) {  // we only display a single combined value for L1 & L2 when L1 and L2 output are summed.
				return
			}

			phases.set(index, data)

			// Update totals for the model.
			let totalPower = NaN
			for (let i = 0; i < consumption.phases.count; ++i) {
				const phaseData = i === index ? data : consumption.phases.get(i)
				if (!phaseData) {
					continue
				}
				totalPower = Units.sumRealNumbers(totalPower, phaseData.power)
			}
			power = totalPower
			if (index === 0) {
				_firstPhaseCurrent = data.current
			}
		}

		function reset() {
			phases.clear()
			power = NaN
			_firstPhaseCurrent = NaN
		}

		readonly property VeQuickItem _maximumCurrent: VeQuickItem {
			uid: Global.acInputs.input1Info.connected ? Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Ac/AcIn1/Consumption/Current/Max"
			   : Global.acInputs.input2Info.connected ? Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Ac/AcIn2/Consumption/Current/Max"
			   : Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Ac/NoAcIn/Consumption/Current/Max"
		}
	}

	function reset() {
		root.consumption.reset()
	}
}
