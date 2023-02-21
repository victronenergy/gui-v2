/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property ListModel model: ListModel {}

	function addInput(input) {
		model.append({ input: input })
	}

	function insertInput(index, input) {
		model.insert(index >= 0 && index < model.count ? index : model.count, { input: input })
	}

	function removeInput(index) {
		model.remove(index)
	}

	function reset() {
		model.clear()
	}

	Component.onCompleted: Global.environmentInputs = root
}
