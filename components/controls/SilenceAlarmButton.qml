/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	leftPadding: leftInset + Theme.geometry_size_16
	rightPadding: rightInset + Theme.geometry_size_16
	defaultBackgroundHeight: Theme.geometry_notificationsPage_snoozeButton_height
	flat: false
	backgroundColor: Theme.color_critical_background
	borderWidth: 0
	icon.source: "qrc:/images/icon_alarm_snooze_24.svg"
	text: CommonWords.silence_alarm

	// ensure highlight border can be seen against critical backgroundColor
	KeyNavigationHighlight.margins: -(4 * Theme.geometry_size_2)

	Binding {
		target: Global.notifications ?? null
		property: "notificationButtonVisible"
		value: root.visible
	}
}
