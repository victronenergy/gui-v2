/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Repeatedly changes data values between the specified minimum and maximum in a linear fashion.
	Values will increase to the maximum, then decrease to the minimum, and repeat.

	This uses a Timer instead of an Animation/Animator, to avoid getting animated property value
	updates in the QML profiler.
*/
Timer {
	// The data values to be updated
	default property list<VeQuickItem> dataItems

	// The min/max value to animate between
	property real minimumValue
	property real maximumValue: 100

	// The preferred step size, and actual step size (which changes when reversing direction)
	property real stepSize: 1
	property list<real> actualStepSizes: []

	// Optional function, to be called with the total value of each dataItem after each update.
	property var notifyTotal

	property bool active: true

	interval: 1000
	running: active && MockManager.timersActive
	repeat: true

	onTriggered: {
		if (maximumValue <= minimumValue) {
			console.warn("Range animator failed: max is <= min, min=%1, max=%2".arg(minimumValue).arg(maximumValue))
			stop()
			return
		}

		let total = 0

		// Ensure step size is set for all data items
		while (actualStepSizes.length < dataItems.length) {
			actualStepSizes.push(stepSize)
		}

		// Update each dataItem value
		for (let i = 0; i < dataItems.length; ++i) {
			if (!dataItems[i]?.uid || isNaN(dataItems[i].value)) {
				continue
			}
			let newValue = dataItems[i].value + actualStepSizes[i]
			if (!isNaN(minimumValue)) {
				newValue = Math.max(minimumValue, newValue)
			}
			if (!isNaN(maximumValue)) {
				newValue = Math.min(maximumValue, newValue)
			}
			dataItems[i].setValue(newValue)

			if (notifyTotal !== undefined) {
				total += newValue
			}

			// Reverse direction if bounds are reached
			if (dataItems[i].value <= minimumValue) {
				actualStepSizes[i] = Math.abs(actualStepSizes[i])
			} else if (dataItems[i].value >= maximumValue) {
				actualStepSizes[i] = Math.abs(actualStepSizes[i]) * -1
			}
		}

		if (notifyTotal !== undefined) {
			notifyTotal(total)
		}
	}
}
