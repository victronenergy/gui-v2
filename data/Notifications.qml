/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property int unacknowledgedCount: NotificationModel.unacknowledgedAlarms
			+ NotificationModel.unacknowledgedWarnings
			+ NotificationModel.unacknowledgedInfos

	readonly property bool statusBarNotificationIconVisible: NotificationModel.activeAlarms > 0
			|| NotificationModel.activeWarnings > 0
			|| NotificationModel.unacknowledgedAlarms > 0
			|| NotificationModel.unacknowledgedWarnings > 0

	readonly property int statusBarNotificationIconPriority: (NotificationModel.activeAlarms > 0 || NotificationModel.unacknowledgedAlarms > 0) ? VenusOS.Notification_Alarm
			: (NotificationModel.activeWarnings > 0 || NotificationModel.unacknowledgedWarnings > 0) ? VenusOS.Notification_Warning
			: (NotificationModel.activeInfos > 0 || NotificationModel.unacknowledgedInfos > 0) ? VenusOS.Notification_Info
			: -1

	readonly property bool silenceAlarmVisible: NotificationModel.unacknowledgedAlarms > 0
			|| NotificationModel.unacknowledgedWarnings > 0

	readonly property bool navBarNotificationCounterVisible: NotificationModel.unacknowledgedAlarms > 0
			|| NotificationModel.unacknowledgedWarnings > 0
			|| NotificationModel.unacknowledgedInfos > 0

	Component.onCompleted: Global.notifications = root
}
