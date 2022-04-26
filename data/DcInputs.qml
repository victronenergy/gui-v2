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

	function removeInput(index) {
		model.remove(index)
	}

	function reset() {
		model.clear()
	}

	Component.onCompleted: Global.dcInputs = root
}
