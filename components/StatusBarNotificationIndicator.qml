/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	width: parent.width
	height: 5

	readonly property color notificationBarColor: Global.notifications?.highestPriortyUnsilenced === VenusOS.Notification_Alarm
												  ? Theme.color_critical
												  : Global.notifications?.highestPriortyUnsilenced === VenusOS.Notification_Warning
													? Theme.color_warning
													: Global.notifications?.highestPriortyUnsilenced === VenusOS.Notification_Info
													  ? Theme.color_ok
													  : root.color

	// Latch the color so it doesn't change while fading out
	onNotificationBarColorChanged: color = notificationBarColor
	opacity: Global.notifications?.showNotificationBar ? 1 : 0
	visible: opacity > 0

	Behavior on opacity {
		OpacityAnimator {
			duration: Theme.animation_page_fade_duration
		}
	}
}
