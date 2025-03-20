/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: gauges

	property alias value: arc.value
	property alias startAngle: arc.startAngle
	property alias endAngle: arc.endAngle
	property int status
	property alias animationEnabled: arc.animationEnabled
	property alias shineAnimationEnabled: arc.shineAnimationEnabled

	Item {
		id: antialiased
		anchors.fill: parent

		// Antialiasing without requiring multisample framebuffers.
		layer.enabled: true
		layer.smooth: true
		layer.textureSize: Qt.size(antialiased.width*2, antialiased.height*2)

		// The single circular gauge is always the battery gauge :. shiny.
		ShinyProgressArc {
			id: arc

			width: gauges.width
			height: width
			anchors.centerIn: parent
			radius: width/2
			startAngle: 0
			endAngle: 359 // "Note that a single PathArc cannot be used to specify a circle."
			progressColor: Theme.color_darkOk,Theme.statusColorValue(gauges.status)
			remainderColor: Theme.color_darkOk,Theme.statusColorValue(gauges.status, true)
			strokeWidth: Theme.geometry_circularSingularGauge_strokeWidth
		}
	}
}
