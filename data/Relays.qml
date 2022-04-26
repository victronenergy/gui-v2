/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property ListModel model: ListModel {}

	function addRelay(relay) {
		model.append({ relay: relay })
	}

	function removeRelay(index) {
		model.remove(index)
	}

	function reset() {
		model.clear()
	}

	Component.onCompleted: Global.relays = root
}
