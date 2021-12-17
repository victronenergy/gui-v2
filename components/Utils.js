/*
** Copyright (C) 2021 Victron Energy B.V.
*/
.pragma library

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

function formatAsHHMM(seconds) {
	if (Number.isNaN(seconds) || seconds < 0)
		return "--:--"

	const duration = decomposeDuration(seconds)
	return pad(duration.h, 2) + ":" + pad(duration.m, 2)
}

function reactToSignalOnce(sig, slot) {
	var f = function() {
		slot.apply(this, arguments)
		sig.disconnect(f)
	}
	sig.connect(f)
}

