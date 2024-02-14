/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as CT
import Victron.VenusOS

CT.ScrollBar {
	id: root

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding)

	leftPadding: Theme.geometry_scrollBar_horizontalMargin
	rightPadding: Theme.geometry_scrollBar_horizontalMargin
	minimumSize: orientation == Qt.Horizontal ? height / width : width / height

	// Hide the scrollbar when there is nothing to scroll.
	// QTBUG-70470: Use ScrollBar.AsNeeded policy once it works
	enabled: parent.contentHeight > parent.height
	opacity: enabled ? 1.0 : 0.0
	Behavior on opacity { OpacityAnimator { duration: Theme.animation_scrollbar_fade_duration; easing: Easing.InOutQuad } }

	background: Item {
		implicitWidth: Theme.geometry_scrollBar_bar_width
		implicitHeight: 100
	}

	contentItem: Rectangle {
		implicitWidth: Theme.geometry_scrollBar_bar_width
		implicitHeight: 100
		radius: Theme.geometry_scrollBar_bar_radius
		color: Theme.color_scrollBar_bar
	}
}
