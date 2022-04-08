/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Shape {
	id: root

	property var model: []
	property int segWidth: width / (model.length - 2)
	readonly property int rc1x: 0.5*segWidth
	readonly property int rc2x: 0.5*segWidth
	property bool enableAnimation: false
	property real offset: 0.0
	property alias strokeColor: shapePath.strokeColor
	property alias strokeWidth: shapePath.strokeWidth
	property alias fillGradient: shapePath.fillGradient
	property alias interval: animation.duration

	function calcY(data) { return (1 - data) * height }

	smooth: true
	layer.enabled: true
	NumberAnimation on offset {
		id: animation

		from: 0
		to: root.segWidth
		duration: Theme.geometry.briefPage.sidePanel.loadGraph.intervalMs
		loops: Animation.Infinite
		running: root.enableAnimation
	}
	ShapePath {
		id: shapePath

		startX: 0
		startY: calcY(model[0])
		strokeWidth: 1

		PathCubic { x: 1 * segWidth - offset; y: calcY(model[1]); relativeControl1X: rc1x - offset; control1Y: calcY(model[0]); relativeControl2X: rc2x - offset; control2Y: y; }
		PathCubic { x: 2 * segWidth - offset; y: calcY(model[2]); relativeControl1X: rc1x; control1Y: calcY(model[1]); relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 3 * segWidth - offset; y: calcY(model[3]); relativeControl1X: rc1x; control1Y: calcY(model[2]); relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 4 * segWidth - offset; y: calcY(model[4]); relativeControl1X: rc1x; control1Y: calcY(model[3]); relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 5 * segWidth - offset; y: calcY(model[5]); relativeControl1X: rc1x; control1Y: calcY(model[4]); relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 6 * segWidth - offset; y: calcY(model[6]); relativeControl1X: rc1x; control1Y: calcY(model[5]); relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 7 * segWidth - offset; y: calcY(model[7]); relativeControl1X: rc1x; control1Y: calcY(model[6]); relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 8 * segWidth - offset; y: calcY(model[8]); relativeControl1X: rc1x; control1Y: calcY(model[7]); relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 9 * segWidth - offset; y: calcY(model[9]); relativeControl1X: rc1x; control1Y: calcY(model[8]); relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 10 * segWidth - offset; y: calcY(model[10]); relativeControl1X: rc1x; control1Y: calcY(model[9]); relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 11 * segWidth - offset; y: calcY(model[11]); relativeControl1X: rc1x; control1Y: calcY(model[10]); relativeControl2X: rc2x; control2Y: y; }

		PathLine { x: root.width + root.strokeWidth; y: calcY(model[11])}
		PathLine { x: root.width + root.strokeWidth; y: root.height + root.strokeWidth }
		PathLine { x: 0 - root.strokeWidth; y: root.height + root.strokeWidth}
		PathLine { x: 0 - root.strokeWidth; y: shapePath.startY}
	}
}

