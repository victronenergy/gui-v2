/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Repeatedly changes data values to a different value within the specified deltas.

	This uses a Timer instead of an Animation/Animator, to avoid getting animated property value
	updates in the QML profiler.
*/
Timer {
	// The data values to be updated
	default property list<VeQuickItem> dataItems

	// The min/max difference in value to shift on each update. E.g. if deltaLow=5, deltaHigh=10,
	// and current value=100, then the new value is between 95-110.
	// If not set, then the defaults are used
	property real deltaLow: NaN
	property real deltaHigh: NaN

	// Optional min/max values
	property real minimumValue: NaN
	property real maximumValue: NaN

	// If set, the randomized value will match the sign of this number. E.g. this is useful when a
	// battery power/current should be negative when the Soc is negative.
	property real followSignOf: NaN

	// Optional function, to be called with (index, newValue) when each dataItem is updated.
	property var notifyUpdate

	// Optional function, to be called with the total value of each dataItem after each set of updates.
	property var notifyTotal

	property bool active: true

	interval: 1000
	running: active && MockManager.timersActive
	repeat: true

	onTriggered: {
		let total = 0

		for (let i = 0; i < dataItems.length; ++i) {
			if (isNaN(dataItems[i].value)) {
				continue
			}

			// If upper delta is not set, default is +10%
			const high = isNaN(deltaHigh) ? dataItems[i].value * 1.1 : dataItems[i].value + deltaHigh

			// If lower delta is not set, default is negative of upper delta (i.e. if both not set,
			// delta is +/- 10%)
			const low = isNaN(deltaLow) ? dataItems[i].value * .9 : dataItems[i].value - deltaLow

			let newValue = (Math.random() * (high - low)) + low
			if (!isNaN(followSignOf)) {
				newValue = Math.abs(newValue) * (followSignOf < 0 ? -1 : 1)
			}
			if (!isNaN(minimumValue)) {
				newValue = Math.max(minimumValue, newValue)
			}
			if (!isNaN(maximumValue)) {
				newValue = Math.min(maximumValue, newValue)
			}
			dataItems[i].setValue(newValue)

			if (notifyUpdate !== undefined) {
				notifyUpdate(i, newValue)
			}
			if (notifyTotal !== undefined) {
				total += newValue
			}
		}

		if (notifyTotal !== undefined) {
			notifyTotal(total)
		}
	}
}
