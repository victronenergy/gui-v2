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

function convertRuntimeToHHMM(runtimeSecs) {
	if (runtimeSecs === -1)
		return "--:--"
	var hours = Math.floor(runtimeSecs / 3600)
	var minutes = Math.floor((runtimeSecs - (hours * 3600)) / 60)
	return pad(hours, 2) + ":" + pad(minutes, 2)
}
