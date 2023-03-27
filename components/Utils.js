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
			if (!!repeater.itemAt(i)) {
				const v = repeater.itemAt(i).yieldValue
				if (v > repeater.maximumYieldValue) {
					repeater.maximumYieldIndex = changedIndex
					repeater.maximumYieldValue = v
				}
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

function formatDaysHours(days, hours) {
	//% "%1d %2h"
	return qsTrId("utils_format_days_hours").arg(days).arg(hours)
}

function formatHoursMinutes(hours, minutes) {
	//% "%1h %2m"
	return qsTrId("utils_format_hours_min").arg(hours).arg(minutes)
}

// Convert number of seconds into readable string
function secondsToString(secs, showSeconds = true) {
	if (secs === undefined) {
		return "---"
	}
	const days = Math.floor(secs / 86400)
	const hours = Math.floor((secs - (days * 86400)) / 3600)
	const minutes = Math.floor((secs - (hours * 3600)) / 60)
	const seconds = Math.floor(secs - (minutes * 60))
	if (days > 0) {
		return formatDaysHours(days, hours)
	}
	if (hours) {
		return formatHoursMinutes(hours, minutes)
	}
	if (minutes) {
		return showSeconds ?
					//% "%1m %2s"
					qsTrId("utils_format_min_sec").arg(minutes).arg(seconds) :
					//% "%1m"
					qsTrId("utils_format_min").arg(minutes)
	}
	return showSeconds ?
				//% "%1s"
				qsTrId("utils_format_sec").arg(seconds) :
				//% "0m"
				qsTrId("utils_zero_minutes")
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

function connmanServiceState(service) {
	if (service) {
		switch (service.state) {
		case "failure":
			//% "Failure"
			return qsTrId("utils_connman_failure")
		case "association":
			//% "Connecting"
			return qsTrId("utils_connman_connecting")
		case "configuration":
			//% "Retrieving IP address"
			return qsTrId("utils_connman_retrieving_ip_address")
		case "ready":
		case "online":
			//% "Connected"
			return qsTrId("utils_connman_connected")
		case "disconnect":
			//% "Disconnect"
			return qsTrId("utils_connman_disconnect")
		}
	}
	//% "Disconnected"
	return qsTrId("utils_connman_disconnected")
}

function uidEndsWithANumber(uid) {
	var array = uid.split('/')
	return( !Number.isNaN(parseInt(array[array.length - 1])))
}

function normalizedSource(s) {
	// strip '/dbus' prefix
	return s.startsWith("dbus/") ? s.substr(5) : s
}

function simplifiedNetworkType(t) {
	if (!t) {
		return ""
	}
	switch (t) {
	case "NONE":
		return ""
	case "GPRS":
	case "GSM":
		return "G"
	case "EDGE":
		return "E"
	case "CDMA":
	case "1xRTT":
	case "IDEN":
		return "2G";
	case "UMTS":
	case "EVDO_0":
	case "EVDO_A":
	case "HSDPA":
	case "HSUPA":
	case "HSPA":
	case "EVDO_B":
	case "EHRPD":
	case "HSPAP":
		return "3G";
	case "LTE":
		return "4G";
	default:
		return t;
	}
}
