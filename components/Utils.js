/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

.pragma library

const SECONDS_PER_DAY = 86400
const SECONDS_PER_HOUR = 3600
const SECONDS_PER_MINUTE = 60
const MS_PER_MINUTE = 60000
const MINUTES_PER_HOUR = 60
const METERS_PER_KILOMETER = 1000
const METERS_PER_MILE = 1609.34
const METERS_PER_NAUTICAL_MILE = 1852

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
	const h = Math.floor(seconds / SECONDS_PER_HOUR)
	const m = Math.floor((seconds - (h * SECONDS_PER_HOUR)) / SECONDS_PER_MINUTE)
	return {
		h: h,
		m: m,
		s: Math.floor(seconds - (h * SECONDS_PER_HOUR + m * SECONDS_PER_MINUTE))
	}
}

function composeDuration(hours, minutes, seconds) {
	return (hours || 0) * SECONDS_PER_HOUR + (minutes || 0) * SECONDS_PER_MINUTE + (seconds || 0)
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
		return showUnits ? "--h --m" : "--:--"
	}

	const duration = decomposeDuration(seconds)
	return pad(duration.h, 2)
			+ (showUnits ? "h " : ":")
			+ pad(duration.m, 2)
			+ (showUnits ? "m " : "")
}

function formatAsHHMMSS(seconds, showUnits) {
	if (Number.isNaN(seconds) || seconds < 0) {
		return "--:--"
	}

	const duration = decomposeDuration(seconds)

	// If hour is present, show it
	let s = pad(duration.m, 2)
		+ (showUnits ? "m " : ":")
		+ pad(duration.s, 2)
		+ (showUnits ? "s" : "")
	if (duration.h > 0) {
		s = pad(duration.h, 2) + (showUnits ? "h:" : ":") + s
	}
	return s
}

function formatGeneratorRuntime(seconds) {
	return seconds < SECONDS_PER_MINUTE
			? secondsToString(seconds)
			: formatAsHHMM(seconds)
}

function formatBatteryTimeToGo(seconds) {
	if (isNaN(seconds) || seconds === 0) {
		return ""
	}
	const text = secondsToString(seconds)
	//: %1 = time remaining, e.g. '3h 2m'
	//% "%1 to go"
	return qsTrId("utils_format_time_to_go").arg(text)
}

function reactToSignalOnce(sig, slot) {
	var f = function() {
		slot.apply(this, arguments)
		sig.disconnect(f)
	}
	sig.connect(f)
}

// Can't use % operator, that gives remainder rather than a modulo that wraps.
function modulo(dividend, divisor) {
	return dividend - divisor * Math.floor(dividend / divisor)
}

function degreesToRadians(degrees) {
	return (degrees * Math.PI / 180)
}

function jsonSettingsToModel(json, expectNumber) {
	if (json === undefined) {
		return []
	}

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
	return keys.map(function(value) {
		let formatted = value
		if (expectNumber) {
			try {
				formatted = parseInt(value)
			} catch (e) {}
		}
		return { display: jsonObject[value], value: formatted }
	})
}

function formatDaysHours(days, hours) {
	//% "%1d %2h"
	return qsTrId("utils_format_days_hours").arg(days).arg(hours)
}

function formatHoursMinutes(hours, minutes) {
	//% "%1h %2m"
	return qsTrId("utils_format_hours_min").arg(hours).arg(minutes)
}

function decomposeSeconds(secs) {
	const days = Math.floor(secs / SECONDS_PER_DAY)
	const hours = Math.floor((secs - (days * SECONDS_PER_DAY)) / SECONDS_PER_HOUR)
	const minutes = Math.floor((secs - (days * SECONDS_PER_DAY) - (hours * SECONDS_PER_HOUR)) / SECONDS_PER_MINUTE)
	const seconds = Math.floor (secs - (days * SECONDS_PER_DAY) - (hours * SECONDS_PER_HOUR) - (minutes * SECONDS_PER_MINUTE))

	return ({
		days: days,
		hours: hours,
		minutes: minutes,
		seconds: seconds
	})
}

// Convert number of seconds into readable string
function secondsToString(secs, showSeconds = true) {
	if (isNaN(secs)) {
		return "--"
	}
	const duration = decomposeSeconds(secs)

	if (duration.days > 0) {
		return formatDaysHours(duration.days, duration.hours)
	}
	if (duration.hours) {
		return formatHoursMinutes(duration.hours, duration.minutes)
	}
	if (duration.minutes) {
		return showSeconds ?
					//% "%1m %2s"
					qsTrId("utils_format_min_sec").arg(duration.minutes).arg(duration.seconds) :
					//% "%1m"
					qsTrId("utils_format_min").arg(duration.minutes)
	}
	return showSeconds ?
				//% "%1s"
				qsTrId("utils_format_sec").arg(duration.seconds) :
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

function formatTimestamp(dateTime, currentDateTime) {
	let ms = Math.floor(currentDateTime - dateTime)
	let minutes = Math.floor(ms / MS_PER_MINUTE)
	if (minutes < 1) {
		//: Indicates an event happened very recently
		//% "now"
		return qsTrId("utils_formatTimestamp_now")
	}
	if (minutes < MINUTES_PER_HOUR) {
		//: Indicates an even happened some minutes before now. %1 = the number of minutes in the past
		//% "%1m ago"
		return qsTrId("utils_formatTimestamp_min_ago").arg(minutes) // eg. "26m ago"
	}
	let hours = Math.floor(minutes / MINUTES_PER_HOUR)
	let days = Math.floor(hours / 24)
	if (days < 1) {
		//: Indicates an even happened some hours and minutes before now. %1 = number of hours in the past, %2 = number of minutes in the past
		//% "%1h %2m ago"
		return qsTrId("utils_formatTimestamp_hours_min_ago").arg(hours).arg(minutes % MINUTES_PER_HOUR) // eg. "2h 10m ago"
	}
	if (days < 7) {
		return dateTime.toLocaleString(Qt.locale(), "ddd hh:mm") // eg. "Mon 09:06"
	}
	return dateTime.toLocaleString(Qt.locale(), "MMM dd hh:mm") // eg. "Mar 27 10:20"
}

function connmanServiceState(state) {
	switch (state) {
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
	case "idle":
	default:
		//% "Disconnected"
		return qsTrId("utils_connman_disconnected")
	}
}

function uidEndsWithANumber(uid) {
	var array = uid.split('/')
	return( !Number.isNaN(parseInt(array[array.length - 1])))
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

// TODO for ListTextItem use, preferably use VeQuickItem::text instead to auto show the hex text
// value from the backend, when that becomes available via MQTT.
function toHexFormat(n) {
	return n ? "0x" + n.toString(16).toUpperCase() : ""
}

// Returns an object to return for text field validation.
//
// If notificationText is set, then when the input is validated prior to an attempted save, a
// a notification of the appropriate type will be shown.
//
// The status can be:
// - InputValidation_Result_Error: the input text is invalid; highlight the input with a red border.
//   Notifications will have an 'error' type.
// - InputValidation_Result_OK: the input text is valid, and can be saved, or red highlight can be
//   removed. Notifications will have an 'info' type.
// - InputValidation_Result_Warning: same as InputValidation_Result_OK, but notifications will have
//   have a 'warning' type.
// - InputValidation_Result_Unknown: the input text should not be saved, but is not invalid, so
//   do not highlight with a red border. This is useful when the input string is empty.
//   Notifications will have an 'info' type.
//
// If adjustedText is set, then the text input field is updated to contain this text.
//
function validationResult(status, notificationText = "", adjustedText = undefined) {
	return { status: status, notificationText: notificationText, adjustedText: adjustedText }
}

function acceptsKeyNavigation(item) {
	return !!item
			&& item.activeFocusOnTab
			&& item.enabled
			&& item.effectiveVisible !== false  // use !== to allow item that do not have effectiveVisible property
}
