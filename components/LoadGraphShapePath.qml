/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Shape {
	id: root

	property var model: []
	readonly property int segWidth: width / Math.max((model.length - 2), 1)
	readonly property int rc1x: 0.5*segWidth
	readonly property int rc2x: 0.5*segWidth
	property real offsetFraction: 0.0
	property real offset: segWidth * offsetFraction
	property alias strokeColor: shapePath.strokeColor
	property alias strokeWidth: shapePath.strokeWidth
	property alias fillGradient: shapePath.fillGradient
	property bool zeroCentered

	property list<real> yValues: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	onModelChanged: yValues = FastUtils.calculateLoadGraphYValues(model, 12, height)

	smooth: true

	// Antialiasing without requiring multisample framebuffers.
	layer.enabled: true
	layer.smooth: true
	layer.textureSize: Qt.size(root.width*2, root.height*2)

	ShapePath {
		id: shapePath

		startX: 0
		startY: yValues[0]
		strokeWidth: 1

		PathCubic { x: 1 * segWidth - offset; y: yValues[1]; relativeControl1X: rc1x - offset; control1Y: yValues[0]; relativeControl2X: rc2x - offset; control2Y: y; }
		PathCubic { x: 2 * segWidth - offset; y: yValues[2]; relativeControl1X: rc1x; control1Y: yValues[1]; relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 3 * segWidth - offset; y: yValues[3]; relativeControl1X: rc1x; control1Y: yValues[2]; relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 4 * segWidth - offset; y: yValues[4]; relativeControl1X: rc1x; control1Y: yValues[3]; relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 5 * segWidth - offset; y: yValues[5]; relativeControl1X: rc1x; control1Y: yValues[4]; relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 6 * segWidth - offset; y: yValues[6]; relativeControl1X: rc1x; control1Y: yValues[5]; relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 7 * segWidth - offset; y: yValues[7]; relativeControl1X: rc1x; control1Y: yValues[6]; relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 8 * segWidth - offset; y: yValues[8]; relativeControl1X: rc1x; control1Y: yValues[7]; relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 9 * segWidth - offset; y: yValues[9]; relativeControl1X: rc1x; control1Y: yValues[8]; relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 10 * segWidth - offset; y: yValues[10]; relativeControl1X: rc1x; control1Y: yValues[9]; relativeControl2X: rc2x; control2Y: y; }
		PathCubic { x: 11 * segWidth - offset; y: yValues[11]; relativeControl1X: rc1x; control1Y: yValues[10]; relativeControl2X: rc2x; control2Y: y; }

		PathLine { x: root.width + root.strokeWidth; y: yValues[11] }
		PathLine { x: root.width + root.strokeWidth; y: root.zeroCentered ? root.height/2 : (root.height + root.strokeWidth) }
		PathLine { x: 0 - root.strokeWidth; y: root.zeroCentered ? root.height/2 : (root.height + root.strokeWidth) }
		PathLine { x: 0 - root.strokeWidth; y: shapePath.startY}
	}
}

