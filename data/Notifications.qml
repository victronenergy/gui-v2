/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property ListModel model: ListModel {}
	property ListModel historyModel: ListModel{}


	function add(input) {
		if (input.acknowledged && !input.active) {
			historyModel.append(input)
		} else {
			model.append(input)
		}
	}

	function deactivate() {
		for (var i = 0; i < model.count; ++i) {
			let notification = model.get(i)
			if (notification.active) {
				notification.active = false
				if (notification.acknowledged === false) {
					model.set(i, notification)
				} else {
					historyModel.insert(0, notification)
					model.remove(i)
				}
				break
			}
		}
	}

	function remove(index) {
		model.remove(index)
	}

	function acknowledge(index) {
		var notification = model.get(index)
		if (notification.acknowledged === false) {
			notification.acknowledged = true
			if (notification.active === false) {
				historyModel.insert(0, notification)
				model.remove(index)
			} else {
				model.set(index, notification)
			}
		}
		notification = Global.notifications.model.get(index)

	}

	function reset() {
		model.clear()
	}

	Component.onCompleted: Global.notifications = root
}
