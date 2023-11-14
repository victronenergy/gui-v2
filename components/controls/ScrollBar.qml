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

	leftPadding: Theme.geometry.scrollBar.horizontalMargin
	rightPadding: Theme.geometry.scrollBar.horizontalMargin
	minimumSize: orientation == Qt.Horizontal ? height / width : width / height

	background: Item {
		implicitWidth: Theme.geometry.scrollBar.bar.width
		implicitHeight: 100
	}

	contentItem: Rectangle {
		implicitWidth: Theme.geometry.scrollBar.bar.width
		implicitHeight: 100
		radius: Theme.geometry.scrollBar.bar.radius
		color: Theme.color.scrollBar.bar
	}
}
