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

	readonly property color statusBarNotificationIconColor: statusBarNotificationIconPriority === VenusOS.Notification_Alarm ? Theme.color_critical
			: statusBarNotificationIconPriority === VenusOS.Notification_Warning ? Theme.color_warning
			: statusBarNotificationIconPriority === VenusOS.Notification_Info ? Theme.color_ok
			: "transparent"

	readonly property url statusBarNotificationIconSource: statusBarNotificationIconPriority === VenusOS.Notification_Info
			? "qrc:/images/icon_info_32.svg" : "qrc:/images/icon_warning_32.svg"

	readonly property bool silenceAlarmVisible: NotificationModel.unacknowledgedAlarms > 0
			|| NotificationModel.unacknowledgedWarnings > 0

	readonly property bool navBarNotificationCounterVisible: NotificationModel.unacknowledgedAlarms > 0
			|| NotificationModel.unacknowledgedWarnings > 0
			|| NotificationModel.unacknowledgedInfos > 0

	property bool notificationButtonVisible

	Component.onCompleted: Global.notifications = root
}
