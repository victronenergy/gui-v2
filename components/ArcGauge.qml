/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS
import Victron.Gauges

// A progress gauge running an on arc, where 0° is at the top, and positive is clockwise
Item {
	id: gauge

	property alias value: arc.value
	property alias startAngle: arc.startAngle
	property alias endAngle: arc.endAngle
	property alias radius: arc.radius
	property alias useLargeArc: arc.useLargeArc
	property alias strokeWidth: arc.strokeWidth
	property alias direction: arc.direction
	property alias animationEnabled: arc.animationEnabled
	property alias progressColor: arc.progressColor
	property alias remainderColor: arc.remainderColor
	property real arcHorizontalCenterOffset
	property real arcVerticalCenterOffset

	Item {
		id: antialiased
		anchors.fill: parent

		// Antialiasing without requiring multisample framebuffers.
		layer.enabled: true
		layer.smooth: true
		layer.textureSize: Qt.size(antialiased.width*2, antialiased.height*2)

		ProgressArc {
			id: arc

			width: radius*2
			height: width
			x: ((gauge.width - width) / 2) + gauge.arcHorizontalCenterOffset
			y: ((gauge.height - height) / 2) + gauge.arcVerticalCenterOffset
		}
	}
}
