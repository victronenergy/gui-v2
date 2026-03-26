/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	leftPadding: leftInset + Theme.geometry_silenceAlarmButton_horizontalPadding
	rightPadding: rightInset + Theme.geometry_silenceAlarmButton_horizontalPadding
	defaultBackgroundHeight: Theme.geometry_notificationsPage_snoozeButton_height
	flat: false
	backgroundColor: Theme.color_critical_background
	borderWidth: 0
	icon.source: "qrc:/images/icon_alarm_snooze_24.svg"
	font.pixelSize: Theme.font_snoozeButton_size
	text: CommonWords.silence_alarm

	// ensure highlight border can be seen against critical backgroundColor
	KeyNavigationHighlight.margins: -(4 * Theme.geometry_button_border_width)

	Binding {
		target: Global.notifications ?? null
		property: "notificationButtonVisible"
		value: root.visible
	}
}
