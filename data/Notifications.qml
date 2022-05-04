/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property ListModel model: ListModel {
		function moveNotificationToHistory(index) {
			if (index < count) {
				var notification = get(index)
				historyModel.insertByDate(notification)
				removeNotification(index)
			} else {
				console.warn("Tried to delete out-of-range notification")
			}
		}
	}
	property ListModel historyModel: ListModel{
		function insertByDate(notification) { // the most recent notification should be at the top of the list
			for (var i = 0; i < count; ++i) {
				var temp = get(i)
				if (notification.date > get(i).date) {
					insert(i, notification)
					return
				}
			}
			append(notification)
		}
	}
	property bool audibleAlarmActive: false
	property bool newNotifications: false // when true, we display a red dot on the 'notifications' button in the nav bar
	property bool snoozeAudibleAlarmActive: false

	function addNotification(notification) {
		if (notification.category === VenusOS.ToastNotification_Category_Error && notification.active) {
			snoozeAudibleAlarmActive = false
		}
		if (notification.acknowledged && !notification.active) {
			historyModel.insert(0, notification)
		} else {
			model.insert(0, notification)
			_handleChanges()
		}
	}

	function removeNotification(index) {
		model.remove(index)
		_handleChanges()
	}

	function acknowledgeNotification(index) {
		var notification = model.get(index)
		if (!notification.acknowledged) {
			notification.acknowledged = true
			updateNotification(index, notification)
			if (!notification.active) {
				model.moveNotificationToHistory(index)
			}
		}
	}

	function reset() {
		model.clear()
		_handleChanges()
	}

	function updateNotification(index, element) {
		model.set(index, element)
		_handleChanges()
	}

	function _handleChanges() {
		let newAudibleAlarmActive = false
		let _newNotifications = false
		for (var i = 0; i < model.count; ++i) {
			var notification = model.get(i)
			if (notification.category === VenusOS.ToastNotification_Category_Error) {
				newAudibleAlarmActive = true
			}
			if (!notification.acknowledged) {
				_newNotifications = true
			}
			if (notification.acknowledged && !notification.active) {
				model.moveNotificationToHistory(i)
			}
		}
		audibleAlarmActive = newAudibleAlarmActive
		newNotifications = _newNotifications
	}

	Component.onCompleted: Global.notifications = root
}
