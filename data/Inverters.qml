/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property ListModel model: ListModel {}

	function addInverter(data) {
		model.append({ inverter: data })
	}

	function removeInverter(index) {
		model.remove(index)
	}

	function reset() {
		model.clear()
	}

	Component.onCompleted: Global.inverters = root
}
