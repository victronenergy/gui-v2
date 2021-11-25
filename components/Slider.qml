/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.Slider {
	id: root

	background: Rectangle {
		x: root.leftPadding
		y: root.topPadding + root.availableHeight / 2 - height / 2
		implicitWidth: 496
		implicitHeight: 8
		width: root.availableWidth
		height: implicitHeight
		radius: 8
		color: Theme.okSecondaryColor

		Rectangle {
			width: root.visualPosition * parent.width
			height: parent.height
			color: Theme.okColor
			radius: 8
		}
	}

	handle: Rectangle {
		x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
		y: root.topPadding + root.availableHeight / 2 - height / 2
		implicitWidth: 24
		implicitHeight: 24
		radius: 12
		color: Theme.primaryFontColor
	}
}
