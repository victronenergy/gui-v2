/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	property alias contentItemChildren: row.children

	anchors {
		right: parent ? parent.rightSideRow.right : undefined
		verticalCenter: parent.verticalCenter
	}
	parent: !!Global.pageManager ? Global.pageManager.statusBar : undefined
	leftPadding: Theme.geometry_silenceAlarmButton_horizontalPadding
	rightPadding: Theme.geometry_silenceAlarmButton_horizontalPadding
	height: Theme.geometry_notificationsPage_snoozeButton_height
	radius: Theme.geometry_button_radius
	opacity: enabled ? 1 : 0
	Behavior on opacity { OpacityAnimator { duration: Theme.animation_toastNotification_fade_duration } }

	contentItem: Row {
		id: row

		anchors.verticalCenter: parent.verticalCenter
		spacing: Theme.geometry_notificationsPage_snoozeButton_spacing
	}
}
