/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

NumberSelectorDialog {
	id: root

	readonly property real transitionValue: 25.0

	title: CommonWords.input_current_limit
	suffix: Units.defaultUnitString(VenusOS.Units_Amp)
	decimals: value <= root.transitionValue ? 1 : 0
	stepSize: value <= root.transitionValue ? 0.1 : 1.0
	to: root.maxCurrentLimit > 0 ? root.maxCurrentLimit : root._presetLimits[root._presetLimits.length - 1]
	presets: _presetAmpOptions()

	stepSizeForValue: (v, increasing) => {
		const epsilon = 0.0001
		const atTransition = Math.abs(v - root.transitionValue) <= epsilon
		return (increasing && atTransition) ? 1.0 : (v <= root.transitionValue ? 0.1 : 1.0)
	}

	customIncrease: (spinbox) => {
		const epsilon = 0.0001
		if (Math.abs(root.value - root.transitionValue) <= epsilon) {
			// we are increasing, but the step size will currently be 0.1 due to the binding.
			// use the larger step size which is appropriate for increasing beyond the transition value.
			root.value = Math.min(root.to, root.value + 1.0)
		} else {
			spinbox.increase()
		}
	}

	property real maxCurrentLimit: -1
	readonly property var _presetLimits: [3.0, 6.0, 10.0, 13.0, 16.0, 25.0, 32.0, 63.0, 100, 150, 200, 300, 500, 750, 1000, 1500, 2000, 2500, 3000, 3500, 4000]
	function _presetAmpOptions() {
		let upperIndex = root._presetLimits.length - 1
		if (root.maxCurrentLimit > 0) {
			// select the 8 values which are (equal to or less than) the max current limit.
			for (let i = 0; i < root._presetLimits.length; ++i) {
				if (root._presetLimits[i] === root.maxCurrentLimit) {
					upperIndex = i
					break
				} else if (root._presetLimits[i] > root.maxCurrentLimit) {
					upperIndex = i - 1
					break
				}
			}
			// also select values which are over the max current limit if necessary, but they will be disabled.
			upperIndex = Math.max(7, upperIndex)
		} else {
			// if we don't know the max current limit, just use the lowest 8 values as presets.
			upperIndex = 7
		}
		const lowerIndex = Math.max(0, upperIndex - 7)
		return root._presetLimits.slice(lowerIndex, upperIndex+1).map(function(v) { return { value: v, enabled: ((root.maxCurrentLimit < 0) || (v <= root.maxCurrentLimit)) } })
	}
}
