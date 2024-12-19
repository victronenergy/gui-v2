/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {

	width: parent.width
	height: 5
	color: Theme.color_critical
	opacity: Global.notifications.unacknowledgedAlarms.count > 0 ? 1 : 0

	Behavior on opacity {
		OpacityAnimator {
			duration: Theme.animation_page_fade_duration
		}
	}
}
