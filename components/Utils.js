/*
** Copyright (C) 2021 Victron Energy B.V.
*/
.pragma library

var maxValues = {}

function arrayCompare(lhs, rhs) {
	if (!Array.isArray(lhs)) {
		if (!Array.isArray(rhs)) {
			return 0
		}
		return 1
	} else if (!Array.isArray(rhs)) {
		return -1
	}

	if (lhs.length < rhs.length) {
		return -1
	} else if (rhs.length < lhs.length) {
		return 1
	}

	for (var i = 0; i < lhs.length; ++i) {
		const lv = lhs[i]
		const rv = rhs[i]
		if (lv < rv) {
			return -1
		} else if (rv < lv) {
			return 1
		}
	}

	return 0
}

function findIndex(container, value) {
	if (Array.isArray(container)) {
		return container.indexof(value)
	} else if ('count' in container) {
		for (var i = 0; i < container.count; ++i) {
			const e = container.get(i)
			if (e === value) {
				return i
			}
		}
	}

	return -1
}

function decomposeDuration(seconds) {
	const h = Math.floor(seconds / 3600)
	const m = Math.floor((seconds - (h * 3600)) / 60)
	return {
		h: h,
		m: m,
		s: Math.floor(seconds - (h * 3600 + m * 60))
	}
}

function composeDuration(hours, minutes, seconds) {
	return (hours || 0) * 3600 + (minutes || 0) * 60 + (seconds || 0)
}

function pad(val, length, char) {
	const str = '' + val
	const n = str.length
	let diff = length - n
	if (diff < 1)
		return str

	let rv = ''
	char = char === undefined ? '0' : char
	while (diff > 0) {
		rv += char
		--diff
	}
	return rv + str
}

function formatAsHHMM(seconds, showUnits) {
	if (Number.isNaN(seconds) || seconds < 0)
		return "--:--"

	const duration = decomposeDuration(seconds)
	return pad(duration.h, 2)
			+ (showUnits ? "h:" : ":")
			+ pad(duration.m, 2)
			+ (showUnits ? "m" : "")
}

function formatAsHHMMSS(seconds, showUnits) {
	if (Number.isNaN(seconds) || seconds < 0)
		return "--:--"

	const duration = decomposeDuration(seconds)

	// If more than 60 minutes, show hours as well
	let s = pad(duration.m, 2)
		+ (showUnits ? "m:" : ":")
		+ pad(duration.s, 2)
		+ (showUnits ? "s" : "")
	if (duration.m > 60) {
		s = pad(duration.h, 2) + (showUnits ? "h:" : ":") + s
	}
	return s
}

function reactToSignalOnce(sig, slot) {
	var f = function() {
		slot.apply(this, arguments)
		sig.disconnect(f)
	}
	sig.connect(f)
}

function updateMaximumValue(key, value) {
	// Set a max value slightly larger than previously known highest value
	if (isNaN(value)) {
		return
	}
	maxValues[key] = Math.max(maxValues[key] || 0, value * 1.2)
}

function maximumValue(key) {
	// TODO should we fetch a max from some data storage preset instead?
	return maxValues[key] || 1  // use default=1 to avoid zero division for ratio calc
}

function batteryIcon(battery) {
	if (!battery || battery.power == 0) {
		return "../images/battery.svg"
	}

	return battery.power > 0 ? "../images/battery_charging.svg" : "../images/battery_discharging.svg"
}

// Can't use % operator, that gives remainder rather than a modulo that wraps.
function modulo(dividend, divisor) {
	return dividend - divisor * Math.floor(dividend / divisor)
}

function degreesToRadians(degrees) {
	return (degrees * Math.PI / 180)
}
