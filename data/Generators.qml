/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		objectProperty: "generator"
	}
	property var first: model.firstObject

	function addGenerator(generator) {
		model.addObject(generator)
	}

	function removeGenerator(generator) {
		model.removeObject(generator.serviceUid)
	}

	function reset() {
		model.clear()
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
