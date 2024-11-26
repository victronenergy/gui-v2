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
	property real initialModelValue: 0.0
	property real offsetFraction
	property real threshold: 0.8    // same as 80% warning level for gauges
	property int dotSize: Theme.geometry_briefPage_sidePanel_loadGraph_dotSize
	property color aboveThresholdFillColor: Theme.color_orange
	property color belowThresholdFillColor: Theme.color_blue
	property color horizontalGradientColor1: Theme.color_briefPage_background
	property color horizontalGradientColor2: "transparent"
	property bool zeroCentered
	property alias active: graphAnimation.running

	signal nextValueRequested

	function addValue(value) {
		model.push(value);
		model.shift();
		orangePath.model = [];
		orangePath.model = root.model;
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
			script: root.nextValueRequested()
		}
	}

	Rectangle {
		anchors.fill: parent
		color: Theme.color_briefPage_background

		LoadGraphShapePath {
			id: orangePath

			anchors.fill: parent
			model: root.model
			strokeColor: aboveThresholdFillColor
			offsetFraction: root.offsetFraction
			fillGradient: LinearGradient {
				x1: 0
				y1: 0
				x2: 0
				y2: height
				GradientStop {
					position: 0
					color: aboveThresholdFillColor
				}
				GradientStop {
					position: 1
					color: "transparent"
				}
			}
		}
	}
	Rectangle {
		anchors.bottom: parent.bottom
		width: parent.width
		height: parent.height * threshold + 1 // '+1' to conceal a 1 pixel orange line from the orange section
		clip: true
		color: Theme.color_briefPage_background

		LoadGraphShapePath {
			id: bluePath
			model: orangePath.model
			strokeColor: belowThresholdFillColor
			height: root.height + 2 * strokeWidth
			width: parent.width + 2 * strokeWidth
			anchors.bottom: parent.bottom
			zeroCentered: root.zeroCentered
			offsetFraction: root.offsetFraction
			fillGradient: LinearGradient {
				x1: 0
				y1: 0
				x2: 0
				y2: height
				GradientStop {
					position: 0
					color: bluePath.zeroCentered ? "transparent" : belowThresholdFillColor
				}
				GradientStop {
					position: 1 - threshold + (dottedLine.height / height)
					color: bluePath.zeroCentered ? Qt.rgba(belowThresholdFillColor.r, belowThresholdFillColor.g, belowThresholdFillColor.b, belowThresholdFillColor.a * 0.5) : belowThresholdFillColor
				}
				GradientStop {
					position: 1
					color: bluePath.zeroCentered ? belowThresholdFillColor : "transparent"
				}
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
	Rectangle {
		// the graph fades out on the sides
		anchors.fill: parent
		gradient: Gradient {
			orientation: Gradient.Horizontal
			GradientStop {
				position: 0
				color: horizontalGradientColor1
			}
			GradientStop {
				position: Theme.geometry_briefPage_sidePanel_loadGraph_horizontalGradient_width / width
				color: horizontalGradientColor2
			}
			GradientStop {
				position: 1 - Theme.geometry_briefPage_sidePanel_loadGraph_horizontalGradient_width / width
				color: horizontalGradientColor2
			}
			GradientStop {
				position: 1
				color: horizontalGradientColor1
			}
		}
	}
	Component.onCompleted: model = Array(Theme.animation_loadGraph_model_length).fill(initialModelValue)
}
