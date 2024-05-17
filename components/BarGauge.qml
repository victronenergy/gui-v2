/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Effects as Effects
import Victron.VenusOS
import Victron.Gauges

BarGaugeBase {
	id: root

	fgRect: foregroundRect

	Rectangle {
		id: maskRect
		layer.enabled: true
		visible: false
		width: root.width
		height: root.height
		radius: root.radius
		color: "black" // opacity mask, not visible.
		z: 1
	}

	Item {
		id: sourceItem
		layer.enabled: true
		visible: false
		width: parent.width
		height: parent.height
		z: 2

		Rectangle {
			id: foregroundRect
			width: parent.width
			height: parent.height
			color: root.foregroundColor
			z: 2 // drawn above the background, but below the border
		}
	}

	Effects.MultiEffect {
		visible: true
		anchors.fill: parent
		maskEnabled: true
		maskSource: maskRect
		source: sourceItem
		z: 3
	}

}
