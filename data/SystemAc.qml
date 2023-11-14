/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property QtObject consumption: QtObject {
		property real power: NaN
		property real current: NaN

		property ListModel phases: ListModel {}

		function setPhaseCount(phaseCount) {
			phases.clear()
			power = NaN
			current = NaN

			for (let i = 0; i < phaseCount; ++i) {
				phases.append({
					name: "L" + (i + 1),
					power: NaN,
					current: NaN
				})
			}
		}

		function setPhaseData(index, data) {
			phases.set(index, data)

			// Update totals for the model.
			let totalPower = NaN
			let totalCurrent = NaN
			for (let i = 0; i < consumption.phases.count; ++i) {
				const phaseData = i === index ? data : consumption.phases.get(i)
				if (!phaseData) {
					continue
				}
				if (!isNaN(phaseData.power)) {
					if (isNaN(totalPower)) {
						totalPower = 0
					}
					totalPower += phaseData.power
				}
				if (!isNaN(phaseData.current)) {
					if (isNaN(totalCurrent)) {
						totalCurrent = 0
					}
					totalCurrent += phaseData.current
				}
			}
			power = totalPower
			current = totalCurrent
		}
	}

	function reset() {
		root.consumption.phases.clear()
		root.consumption.power = NaN
		root.consumption.current = NaN
	}
}
