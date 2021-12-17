/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls.impl
import Victron.VenusOS

Item {
	id: gauges

	property var model
	readonly property real step: Theme.geometry.circularMultiGauge.spacing
	readonly property real strokeWidth: Theme.geometry.circularMultiGauge.strokeWidth

	Item {
		id: gaugeContainer
		anchors.fill: parent
		anchors.margins: gauges.strokeWidth/2

		// Antialiasing
		layer.enabled: true
		layer.samples: 4

		Repeater {
			width: parent.width
			model: gauges.model
			delegate: ProgressArc {
				property int status: Gauges.getValueStatus(model.value, model.valueType)
				width: parent.width - (strokeWidth + index*step)
				height: width
				anchors.centerIn: parent
				radius: width/2
				startAngle: 0
				endAngle: 270
				value: model.value
				progressColor: Theme.statusColorValue(status)
				remainderColor: Theme.statusColorValue(status, true)
				strokeWidth: gauges.strokeWidth
			}
		}
	}

	Item {
		id: textCol

		anchors.top: parent.top
		anchors.bottom: parent.verticalCenter
		anchors.left: parent.left
		anchors.right: parent.horizontalCenter
		anchors.rightMargin: Theme.geometry.circularMultiGauge.labels.rightMargin

		Repeater {
			width: parent.width
			model: gauges.model
			delegate:Label {
				y: gaugeContainer.anchors.margins/3 + (index*gauges.step/2)
				width: parent.width
				horizontalAlignment: Text.AlignRight
				font.pixelSize: Theme.font.size.m
				color: Theme.color.font.primary
				text: qsTrId(model.textId)

				ColorImage {
					anchors.left: parent.right
					anchors.leftMargin: Theme.geometry.circularMultiGauge.labels.spacing
					anchors.verticalCenter: parent.verticalCenter
					source: model.icon
					color: Theme.color.font.primary
					fillMode: Image.PreserveAspectFit
					smooth: true
				}
			}
		}
	}
}
