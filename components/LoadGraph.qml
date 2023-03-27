/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Item {
	id: root

	property var model: [] // contains 12 values that define the shape of our bendy graph
	property real initialModelValue: 0.0
	property real warningThreshold: Theme.geometry.briefPage.sidePanel.loadGraph.warningThreshold
	property int dotSize: Theme.geometry.briefPage.sidePanel.loadGraph.dotSize
	property int interval: Theme.geometry.briefPage.sidePanel.loadGraph.intervalMs
	property bool enableAnimation: false
	property color belowThresholdFillColor1: Theme.color.briefPage.sidePanel.loadGraph.nominal.gradientColor1
	property color belowThresholdFillColor2: Theme.color.briefPage.sidePanel.loadGraph.nominal.gradientColor2
	property color belowThresholdBackgroundColor1: Theme.color.briefPage.background
	property color belowThresholdBackgroundColor2: Theme.color.briefPage.background
	property color horizontalGradientColor1: Theme.color.briefPage.background
	property color horizontalGradientColor2: Theme.color.briefPage.sidePanel.loadGraph.horizontalGradient.color

	function addValue(value) {
		model.push(value)
		model.shift()
		orangePath.model = []
		orangePath.model = root.model
	}

	implicitWidth: Theme.geometry.briefPage.sidePanel.loadGraph.width
	implicitHeight: Theme.geometry.briefPage.sidePanel.loadGraph.height

	Rectangle {
		anchors.fill: parent
		color: Theme.color.briefPage.background

		LoadGraphShapePath {
			id: orangePath

			anchors.fill: parent
			model: root.model
			strokeColor: Theme.color.briefPage.sidePanel.loadGraph.warning.strokeColor
			interval: root.interval
			enableAnimation: root.enableAnimation
			fillGradient: LinearGradient {
				x1: 0; y1: 0
				x2: 0; y2: height
				GradientStop { position: 0; color: Theme.color.briefPage.sidePanel.loadGraph.warning.gradientColor1 }
				GradientStop { position: 1; color: Theme.color.briefPage.sidePanel.loadGraph.warning.gradientColor2 }
			}
		}
	}
	Rectangle {
		anchors.bottom: parent.bottom
		width: parent.width
		height: parent.height * warningThreshold + 1 // '+1' to conceal a 1 pixel orange line from the orange section
		clip: true

		gradient: Gradient {
			GradientStop { position: 0; color: belowThresholdBackgroundColor2 }
			GradientStop { position: 1; color: belowThresholdBackgroundColor1 }
		}

		LoadGraphShapePath {
			id: bluePath
			model: orangePath.model
			strokeColor: Theme.color.briefPage.sidePanel.loadGraph.nominal.strokeColor
			height: root.height + 2*strokeWidth
			width: parent.width + 2*strokeWidth
			anchors.bottom: parent.bottom
			interval: root.interval
			enableAnimation: root.enableAnimation
			fillGradient: LinearGradient {
				x1: 0; y1: 0
				x2: 0; y2: height
				GradientStop { position: 0; color: belowThresholdFillColor1 }
				GradientStop {
					position: 1 - warningThreshold + (dottedLine.height / height)
					color: belowThresholdFillColor1
				}
				GradientStop { position: 1; color: belowThresholdFillColor2 }
			}
		}
		Row {
			id: dottedLine

			width: parent.width
			height: dotSize
			spacing: dotSize

			Repeater {
				model: dottedLine.width / (dotSize + dottedLine.spacing)
				delegate: Rectangle {
					implicitWidth: dotSize
					implicitHeight: dotSize
					color: Theme.color.briefPage.sidePanel.loadGraph.dotColor
				}
			}
		}
	}
	Rectangle { // the graph fades out on the sides
		anchors.fill: parent
		gradient: Gradient {
			orientation: Gradient.Horizontal
			GradientStop { position: 0; color: horizontalGradientColor1 }
			GradientStop {
				position: Theme.geometry.briefPage.sidePanel.loadGraph.horizontalGradient.width/width
				color: horizontalGradientColor2
			}
			GradientStop {
				position: 1 - Theme.geometry.briefPage.sidePanel.loadGraph.horizontalGradient.width/width
				color: horizontalGradientColor2
			}
			GradientStop { position: 1; color: horizontalGradientColor1 }
		}
	}
	Component.onCompleted: model = Array(Theme.animation.loadGraph.model.length).fill(initialModelValue)
}
