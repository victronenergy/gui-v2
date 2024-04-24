/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Item {
	id: root

	property var model: [] // contains 12 values that define the shape of our bendy graph
	property var getNextValue   // function that returns next value (0.0 - 1.0) to be added to the graph
	property real initialModelValue: 0.0
	property real offsetFraction
	property real warningThreshold: Theme.geometry_briefPage_sidePanel_loadGraph_warningThreshold
	property int dotSize: Theme.geometry_briefPage_sidePanel_loadGraph_dotSize
	property color belowThresholdFillColor1: Theme.color_briefPage_sidePanel_loadGraph_nominal_gradientColor1
	property color belowThresholdFillColor2: Theme.color_briefPage_sidePanel_loadGraph_nominal_gradientColor2
	property color belowThresholdBackgroundColor1: Theme.color_briefPage_background
	property color belowThresholdBackgroundColor2: Theme.color_briefPage_background
	property color horizontalGradientColor1: Theme.color_briefPage_background
	property color horizontalGradientColor2: Theme.color_briefPage_sidePanel_loadGraph_horizontalGradient_color
	property alias active: graphAnimation.running

	function addValue(value) {
		model.push(value)
		model.shift()
		orangePath.model = []
		orangePath.model = root.model
	}

	implicitWidth: Theme.geometry_briefPage_sidePanel_loadGraph_width
	implicitHeight: Theme.geometry_briefPage_sidePanel_loadGraph_height

	SequentialAnimation {
		id: graphAnimation

		loops: Animation.Infinite

		NumberAnimation {
			target: root
			property: "offsetFraction"
			from: 0.0
			to: 1.0
			duration: Theme.geometry_briefPage_sidePanel_loadGraph_intervalMs
		}

		ScriptAction {
			script: root.addValue(root.getNextValue())
		}
	}

	Rectangle {
		anchors.fill: parent
		color: Theme.color_briefPage_background

		LoadGraphShapePath {
			id: orangePath

			anchors.fill: parent
			model: root.model
			strokeColor: Theme.color_briefPage_sidePanel_loadGraph_warning_strokeColor
			offsetFraction: root.offsetFraction
			fillGradient: LinearGradient {
				x1: 0; y1: 0
				x2: 0; y2: height
				GradientStop { position: 0; color: Theme.color_briefPage_sidePanel_loadGraph_warning_gradientColor1 }
				GradientStop { position: 1; color: Theme.color_briefPage_sidePanel_loadGraph_warning_gradientColor2 }
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
			strokeColor: Theme.color_briefPage_sidePanel_loadGraph_nominal_strokeColor
			height: root.height + 2*strokeWidth
			width: parent.width + 2*strokeWidth
			anchors.bottom: parent.bottom
			offsetFraction: root.offsetFraction
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
					color: Theme.color_briefPage_sidePanel_loadGraph_dotColor
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
				position: Theme.geometry_briefPage_sidePanel_loadGraph_horizontalGradient_width/width
				color: horizontalGradientColor2
			}
			GradientStop {
				position: 1 - Theme.geometry_briefPage_sidePanel_loadGraph_horizontalGradient_width/width
				color: horizontalGradientColor2
			}
			GradientStop { position: 1; color: horizontalGradientColor1 }
		}
	}
	Component.onCompleted: model = Array(Theme.animation_loadGraph_model_length).fill(initialModelValue)
}
