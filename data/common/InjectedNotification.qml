/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseNotification {
	id: notification

	property alias text: _privateParser.text

	onUpdateAcknowledged: (acknowledged) => {
							  notification.acknowledged = acknowledged
							  // since injected notifications don't have the idea
							  // of being active or not, we set it active: false
							  // when it is acknowledged for now.
							  notification.active = false
						  }

	onUpdateActive: (active) => {
						notification.active = active
					}

	readonly property QtObject _private: QtObject {
		id: _privateParser

		property string text
		property int first: text.indexOf("\t")
		property int second: text.indexOf("\t", first + 1)
		property bool parseValid: first > 0 && second > first
		property int type: parseValid ? text.slice(0, first) : -1
		property string deviceName: parseValid ? text.slice(first + 1, second) : ""
		property string description: parseValid ? text.slice(second + 1, text.length) : ""
		property bool canInitialize: type > -1 && deviceName.length && description.length

		onCanInitializeChanged: if (canInitialize) {
									// insert into the allNotificationsModel
									Global.notifications.allNotificationsModel?.insertNotification(notification)
								}
	}

	// Note: notificationId and value properties
	// are not provided by the injected text format.
	acknowledged: false // default value
	active: true // default value
	type: _privateParser.type
	deviceName: _privateParser.deviceName
	description: _privateParser.description
	dateTime: new Date()
	value: ""

	Component.onDestruction: {
		// remove from the allNotificationsModel
		Global.notifications.allNotificationsModel.removeNotification(notification)
	}
}
