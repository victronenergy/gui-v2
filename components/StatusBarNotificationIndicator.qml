/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {

	width: parent.width
	height: 5
	color: Global.notifications.unacknowledgedModel.highestPriorityType === VenusOS.Notification_Alarm
		   ? Theme.color_critical
		   : Global.notifications.unacknowledgedModel.highestPriorityType === VenusOS.Notification_Warning
			 ? Theme.color_warning
			 : Theme.color_ok
	opacity: Global.notifications.unacknowledgedModel.count > 0 ? 1 : 0
	visible: opacity > 0

	Behavior on opacity {
		OpacityAnimator {
			duration: Theme.animation_page_fade_duration
		}
	}
}
