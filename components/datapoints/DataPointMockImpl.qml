/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQml

QtObject {
	id: root

	property var value
	property var min
	property var max

	function setValue(v) {
		value = v
	}
}
