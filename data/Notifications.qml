/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property ListModel model: ListModel {}
	property ListModel historyModel: ListModel{}
	property bool audibleAlarmActive: false
	property bool snoozeAudibleAlarmActive: false
	property var page


	function handleChanges() {
		console.log("Notifications: handleChanges")
		let newAudibleAlarmActive = false
		for (var i = 0; i < model.count; ++i) {
			var notification = model.get(i)
			if (notification.category === VenusOS.ToastNotification_Category_Error) {
				newAudibleAlarmActive = true
			}
		}
		audibleAlarmActive = newAudibleAlarmActive
	}

	function add(input) {
		if (input.acknowledged && !input.active) {
			historyModel.append(input)
		} else {
			model.append(input)
			handleChanges()
		}
	}

	function update(index, element) {
		model.set(index, element)
		handleChanges()
	}

	function deactivate() {
		for (var i = 0; i < model.count; ++i) {
			let notification = model.get(i)
			if (notification.active) {
				notification.active = false
				if (notification.acknowledged === false) {
					update(i, notification)
				} else {
					historyModel.insert(0, notification)
					remove(i)
				}
				break
			}
		}
	}

	function remove(index) {
		model.remove(index)
		handleChanges()
	}

	function acknowledge(index) {
		var notification = model.get(index)
		if (notification.acknowledged === false) {
			notification.acknowledged = true
			if (notification.active === false) {
				historyModel.insert(0, notification)
				remove(index)
			} else {
				update(index, notification)
			}
		}
		notification = Global.notifications.model.get(index)
	}

	function reset() {
		model.clear()
		handleChanges()
	}

	Component.onCompleted: Global.notifications = root
}
