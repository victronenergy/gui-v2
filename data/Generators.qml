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

	function manualRunningNotification(start, startDuration = 0) {
		if (start) {
			if (startDuration > 0) {
				//% "Starting; the generator will stop in %1, unless other conditions keep it running."
				Global.notificationLayer.showToastNotification(VenusOS.Notification_Info,
						qsTrId("controlcard_generator_manual_start_notice").arg(Utils.secondsToString(startDuration)))
			} else {
				//% "Starting; the generator will not stop until user intervention."
				Global.notificationLayer.showToastNotification(VenusOS.Notification_Info,
						qsTrId("controlcard_generator_manual_start_with_duration_notice"))
			}
		} else {
			//% "Stopping; the generator will continue to run if other conditions are reached."
			Global.notificationLayer.showToastNotification(VenusOS.Notification_Info,
					qsTrId("controlcard_generator_manual_stop_notice"))
		}
	}

	Component.onCompleted: Global.generators = root
}
