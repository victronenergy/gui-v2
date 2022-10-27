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
	if (diff < 1) {
		return str
	}

	let rv = ''
	char = char === undefined ? '0' : char
	while (diff > 0) {
		rv += char
		--diff
	}
	return rv + str
}

function formatAsHHMM(seconds, showUnits) {
	if (Number.isNaN(seconds) || seconds < 0) {
		return "--:--"
	}

	const duration = decomposeDuration(seconds)
	return pad(duration.h, 2)
			+ (showUnits ? "h:" : ":")
			+ pad(duration.m, 2)
			+ (showUnits ? "m" : "")
}

function formatAsHHMMSS(seconds, showUnits) {
	if (Number.isNaN(seconds) || seconds < 0) {
		return "--:--"
	}

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

function scaleToRange(value, valueMin, valueMax, scaledMin, scaledMax) {
	if (valueMin >= valueMax) {
		console.warn("scaleToRange() failed, valueMin", valueMin, ">= valueMax", valueMax)
		return value
	}
	if (scaledMin >= scaledMax) {
		console.warn("scaleToRange() failed, scaledMin", scaledMin, ">= valueMax", scaledMax)
		return value
	}
	if (value < valueMin || value > valueMax) {
		console.warn("scaleToRange() failed, value", value, "not within range", valueMin, valueMax)
		return value
	}

	const origRange = valueMax - valueMin
	const scaledRange = scaledMax - scaledMin
	return scaledRange * (value / origRange)
}

// Can't use % operator, that gives remainder rather than a modulo that wraps.
function modulo(dividend, divisor) {
	return dividend - divisor * Math.floor(dividend / divisor)
}

function degreesToRadians(degrees) {
	return (degrees * Math.PI / 180)
}

// This considers whether the values are NaN. If both are NaN, the result is NaN.
function sumRealNumbers(a, b) {
	return isNaN(a) && isNaN(b)
		? NaN
		: isNaN(a)
		  ? b
		  : isNaN(b)
			? a
			: a + b
}

function updateMaximumYield(repeater, changedIndex, changedYieldValue) {
	if (repeater.maximumYieldIndex === changedIndex) {
		for (let i = 0; i < repeater.count; ++i) {
			const v = repeater.itemAt(i).yieldValue
			if (v > repeater.maximumYieldValue) {
				repeater.maximumYieldIndex = changedIndex
				repeater.maximumYieldValue = v
			}
		}
	} else if (changedYieldValue > repeater.maximumYieldValue) {
		repeater.maximumYieldIndex = changedIndex
		repeater.maximumYieldValue = changedYieldValue
	}
}

function jsonSettingsToModel(json) {
	let jsonObject
	if (typeof(json) === "string") {
		try {
			jsonObject = JSON.parse(json)
		} catch (e) {
			console.warn("Unable to parse JSON:", json, "exception:", e)
			return null
		}
	} else {
		jsonObject = json
	}

	let keys = Object.keys(jsonObject)
	let modelArray = []
	for (let i = 0; i < keys.length; i++) {
		modelArray.push({ display: jsonObject[keys[i]], value: keys[i] })
	}
	return modelArray
}

function toFloat(value, precision) {
	const factor = Math.pow(10, precision)
	return Math.round(value * factor) / factor
}

// Convert number of seconds into readable string
function secondsToString(secs) {
	if (secs === undefined) {
		return "---"
	}
	const days = Math.floor(secs / 86400)
	const hours = Math.floor((secs - (days * 86400)) / 3600)
	const minutes = Math.floor((secs - (hours * 3600)) / 60)
	const seconds = Math.floor(secs - (minutes * 60))
	if (days > 0) {
		//% "%1d %2h"
		return qsTrId("utils_format_days_hours").arg(days).arg(hours)
	}
	if (hours) {
		//% "%1h %2m"
		return qsTrId("utils_format_hours_min").arg(hours).arg(minutes)
	}
	if (minutes) {
		//% "%1m %2s"
		return qsTrId("utils_format_min_sec").arg(minutes).arg(seconds)
	}
	//% "%1s"
	return qsTrId("utils_format_sec").arg(seconds)
}

// Convert a timestamp into a relative readable string, for example '1d 2h'
function timeAgo(timestamp) {
	var timeNow = Math.round(Date.now() / 1000)
	var timeAgo = "---"
	if (timestamp !== undefined && timestamp > 0) {
		timeAgo = secondsToString(timeNow - timestamp)
	}
	return timeAgo;
}

// Convert 1000000 to '10M items' or '1 file', etc.
// TODO - this matches the old gui implementation, but is unusual in that it returns eg. "1127.96M bytes"
// instead of the more familiar "1127.96MB". Check with victron.
function qtyToString(qty, unitSingle, unitMultiple) {
	if (qty > 1000000) {
		return "%1M %2".arg(Math.round((qty * 100) / 1000000) / 100).arg(unitMultiple)
	} else if (qty > 1000) {
		return "%1k %2".arg(Math.round((qty * 100) / 1000) / 100).arg(unitMultiple)
	} else if (qty > 1 || qty === 0) {
		return "%1 %2".arg(qty).arg(unitMultiple)
	} else if (qty === 1) {
		return "1 %1".arg(unitSingle)
	} else {
		return "---"
	}
}

function qsTrIdServiceType(serviceType) {
	switch (serviceType) {
	case "grid":
		//% "Grid meter"
		return qsTrId("settings_grid_meter")
	case "pvinverter":
		//% "PV inverter"
		return qsTrId("settings_pv_inverter")
	case "genset":
		//% "Generator"
		return qsTrId("settings_generator")
	case "acload":
		//% "AC load"
		return qsTrId("settings_ac_load")
	default:
		return '--'
	}
}
