/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: gauges

	property var model
	readonly property real strokeWidth: Theme.geometry.circularSingularGauge.strokeWidth
	property alias caption: captionLabel.text

	Item {
		anchors.fill: parent

		// Antialiasing
		layer.enabled: true
		layer.samples: 4

		ProgressArc {
			property int status: model ? Gauges.getValueStatus(model.value, model.valueType) : 0
			
			width: gauges.width - strokeWidth
			height: width
			anchors.centerIn: parent
			radius: width/2
			startAngle: 0
			endAngle: 360
			value: model ? model.value : 0
			progressColor: Theme.statusColorValue(status)
			remainderColor: Theme.statusColorValue(status, true)
			strokeWidth: gauges.strokeWidth
		}
	}

	Column {
		anchors.centerIn: parent
		
		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 6

			CP.ColorImage {
				id: icon
				source: model ? model.icon : ""
				color: Theme.color.font.primary
				fillMode: Image.PreserveAspectFit
				smooth: true
			}
			Label {
				anchors.verticalCenter: icon.verticalCenter
				font.pixelSize: Theme.font.size.m
				color: Theme.color.font.primary
				text: model ? model.name : ""
			}
		}

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 6

			Label {
				font.pixelSize: Theme.font.size.xxxl
				color: Theme.color.font.primary
				text: model ? model.value : ""
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
