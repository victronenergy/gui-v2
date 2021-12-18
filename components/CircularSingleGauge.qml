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

	Item {
		anchors.fill: parent

		// Antialiasing
		layer.enabled: true
		layer.samples: 4

		ProgressArc {
			property int status: Gauges.getValueStatus(model.value, model.valueType)
			
			width: gauges.width - strokeWidth
			height: width
			anchors.centerIn: parent
			radius: width/2
			startAngle: 0
			endAngle: 360
			value: model.value
			progressColor: Theme.statusColorValue(status)
			remainderColor: Theme.statusColorValue(status, true)
			strokeWidth: gauges.strokeWidth
		}
	}

	Column {
		anchors.bottom: parent.bottom
		anchors.bottomMargin: Theme.geometry.circularSingularGauge.labels.bottomMargin
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: -6
		
		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 6

			CP.ColorImage {
				id: icon
				source: model.icon
				color: Theme.color.font.primary
				fillMode: Image.PreserveAspectFit
				smooth: true
			}
			Label {
				anchors.verticalCenter: icon.verticalCenter
				font.pixelSize: Theme.font.size.m
				color: Theme.color.font.primary
				text: qsTrId(model.textId)
			}
		}

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 6

			Label {
				font.pixelSize: Theme.font.size.xxxl
				color: Theme.color.font.primary
				text: model.value
			}
			Label {
				font.pixelSize: Theme.font.size.xxxl
				color: Theme.color.font.primary
				opacity: 0.7
				text: '%'
			}
		}
	}
}
