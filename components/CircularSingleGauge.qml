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
	property alias shineAnimationEnabled: arc.shineAnimationEnabled

	Item {
		anchors.fill: parent

		// Antialiasing
		layer.enabled: true
		layer.samples: 4

		ProgressArc {
			id: arc

			width: gauges.width
			height: width
			anchors.centerIn: parent
			radius: width/2
			startAngle: 0
			endAngle: 360
			progressColor: Theme.statusColorValue(gauges.status)
			remainderColor: Theme.statusColorValue(gauges.status, true)
			strokeWidth: Theme.geometry.circularSingularGauge.strokeWidth
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
