/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import "/components/Gauges.js" as Gauges

Item {
	id: gauges

	property alias icon: icon
	property alias name: nameLabel.text
	property alias value: arc.value
	property int status
	property alias caption: captionLabel.text
	property alias animationEnabled: arc.animationEnabled

	Item {
		id: antialiased
		anchors.fill: parent

		// Antialiasing without requiring multisample framebuffers.
		layer.enabled: true
		layer.smooth: true
		layer.textureSize: Qt.size(antialiased.width*2, antialiased.height*2)

		ProgressArc2 {
			id: arc

			width: gauges.width
			height: width
			anchors.centerIn: parent
			radius: width/2 - strokeWidth/2
			startAngle: 0
			endAngle: 360
			progressColor: Theme.statusColorValue(gauges.status)
			remainderColor: Theme.statusColorValue(gauges.status, true)
			strokeWidth: Theme.geometry.circularSingularGauge.strokeWidth

			Timer {
				id: dbgTimerXXXXXXXXXXXXXXX
				interval: 2000
				running: true
				repeat: true
				property bool toggle
				onTriggered: {
					toggle = !toggle
					arc.progressColor = toggle ? Theme.statusColorValue(gauges.status) : "blue"
				}
			}
		}
	}

	Column {
		anchors.centerIn: parent

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 6

			CP.ColorImage {
				id: icon

				color: Theme.color.font.primary
				fillMode: Image.PreserveAspectFit
				smooth: true
			}
			Label {
				id: nameLabel

				anchors.verticalCenter: icon.verticalCenter
				font.pixelSize: Theme.font.size.m
				color: Theme.color.font.primary
			}
		}

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 6

			Label {
				font.pixelSize: Theme.font.size.xxxl
				color: Theme.color.font.primary
				text: gauges.value
			}
			Label {
				font.pixelSize: Theme.font.size.xxxl
				color: Theme.color.font.secondary
				text: '%'
			}
		}

		Label {
			id: captionLabel

			anchors.horizontalCenter: parent.horizontalCenter
			font.pixelSize: Theme.font.size.s
			color: Theme.color.font.secondary
		}
	}
}
