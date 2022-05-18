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
			endAngle: 360
			progressColor: Theme.statusColorValue(gauges.status)
			remainderColor: Theme.statusColorValue(gauges.status, true)
			strokeWidth: Theme.geometry.circularSingularGauge.strokeWidth
		}
	}

	Column {
		anchors.centerIn: parent
		spacing: Theme.geometry.briefPage.centerGauge.centerTextSpacing

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
				font.pixelSize: Theme.font.size.body2
				color: Theme.color.font.primary
			}
		}

		QuantityLabel {
			anchors.horizontalCenter: parent.horizontalCenter
			font.pixelSize: Theme.font.size.h5
			unit: VenusOS.Units_Percentage
			value: gauges.value
		}

		Label {
			id: captionLabel

			anchors.horizontalCenter: parent.horizontalCenter
			font.pixelSize: Theme.font.size.body1
			color: Theme.color.font.secondary
		}
	}
}
