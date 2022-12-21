/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property ListModel model: ListModel {}
	property var first  // the generator with the lowest DeviceInstance

	function addGenerator(generator) {
		model.append({ generator: generator })
	}

	function removeGenerator(index) {
		model.remove(index)
	}

	function reset() {
		model.clear()
	}

	function refreshFirstGenerator() {
		if (model.count === 0) {
			return
		}
		let candidate = model.get(0).generator
		for (let i = 1; i < model.count; ++i) {
			const currentGenerator = model.get(i).generator
			if (currentGenerator.deviceInstance >= 0
					&& currentGenerator.deviceInstance < candidate.deviceInstance) {
				candidate = currentGenerator
			}
		}
		Global.generators.first = candidate
	}

	Component.onCompleted: Global.generators = root
}
