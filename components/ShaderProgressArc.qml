/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: gauge

	property real value // from 0.0 to 100.0
	property color remainderColor: Theme.color.darkOk
	property color progressColor: Theme.color.ok
	property real startAngle: 270
	property real endAngle: startAngle + Theme.geometry.briefPage.smallEdgeGauge.maxAngle
	property real progressAngle: startAngle + ((endAngle - startAngle) * Math.min(Math.max(gauge.value, 0.0), 100.0) / 100.0)
	property real strokeWidth: width/25
	property real radius: Theme.geometry.briefPage.edgeGauge.radius
	property real smoothing: 1 // how many pixels of antialiasing to apply.
	property bool clockwise: true
	property bool animationEnabled: true

	// the radius of the outermost part of the arc we draw.
	// we scale everything to uv coordinates with respect to
	// the origin of a circle with this radius.
	readonly property real _maxRadius: gauge.radius + gauge.strokeWidth/2 + 2*gauge.smoothing
	// when we calculate the uv coordinate transformations,
	// leave just enough of the opposite quadrant visible
	// so that we can draw the startcap.
	readonly property real _startcapAmount: ((strokeWidth/2 + 2*smoothing)/_maxRadius)
	property real _normalizedRadiansFactor: (Math.PI/180) / (2*Math.PI)

	onProgressAngleChanged: {
		if (!progressAnimator.running) {
			progressAnimator.from = shader.progressAngle
			progressAnimator.to = gauge.progressAngle * gauge._normalizedRadiansFactor
			progressAnimator.start()
		}
	}

	ShaderEffect {
		id: shader
		anchors.fill: parent
		fragmentShader: "shaders/progressarc.frag.qsb"

		property color remainderColor: gauge.remainderColor
		property color progressColor: gauge.progressColor
		// transform angles to radians and then normalize
		property real startAngle: gauge.startAngle * gauge._normalizedRadiansFactor
		property real endAngle: gauge.endAngle * gauge._normalizedRadiansFactor
		property real progressAngle: -1.0
		// transform radii to uv coords
		property real innerRadius: (gauge.radius - gauge.strokeWidth/2 - gauge.smoothing)/gauge._maxRadius
		property real radius: gauge.radius/gauge._maxRadius
		property real outerRadius: (gauge.radius + gauge.strokeWidth/2 + gauge.smoothing)/gauge._maxRadius
		// transform smoothing pixels to uv distance
		property real smoothing: gauge.smoothing / gauge._maxRadius
		property real clockwise: gauge.clockwise ? 1.0 : 0.0
		// perform some uv transformations to "clip" the viewport to the section of the arc.
		property real xscale: (gauge.width/gauge._maxRadius)
		property real xtranslate: ((gauge.clockwise && (gauge.startAngle > 180.0)) || (!gauge.clockwise && gauge.startAngle < 180))
			? -1.0 // left gauges
			: (1-(gauge.width/gauge._maxRadius)) // right gauges
		property real yscale: (gauge.height/gauge._maxRadius)
		property real ytranslate: (gauge.startAngle < 180.0) ? (0.0 - gauge._startcapAmount) // small gauges, in bottom left or bottom right quadrants
			: (gauge.startAngle < 270.0) ? -((gauge.height/gauge._maxRadius)/2) // large gauges
			: ((-gauge.height/gauge._maxRadius) + gauge._startcapAmount) // small gauges, in top left or top right quadrants

		UniformAnimator {
			id: progressAnimator
			target: shader
			uniform: "progressAngle"
			duration: Theme.animation.progressArc.duration
			easing.type: Easing.InOutQuad
		}
	}
}
