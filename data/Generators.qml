/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property ListModel model: ListModel {}
	property var first  // the first valid generator

	function addGenerator(generator) {
		model.append({ generator: generator })
	}

	function removeGenerator(index) {
		model.remove(index)
	}

	function reset() {
		model.clear()
	}

	Component.onCompleted: Global.generators = root
}
