import QtQuick
import Victron.VenusOS

Item {
	id: gauge

	property real value // from 0.0 to 100.0
	property color remainderColor: "gray"
	property color progressColor: "blue"
	property color shineColor: Qt.rgba(1.0, 1.0, 1.0, 0.80)
	property real startAngle: 0
	property real endAngle: 270
	property real progressAngle: startAngle + ((endAngle - startAngle) * Math.min(Math.max(gauge.value, 0.0), 100.0) / 100.0)
	property real strokeWidth: width/25
	property real radius: (width - strokeWidth - smoothing)/2
	property real smoothing: 1 // how many pixels of antialiasing to apply.
	property bool clockwise: true
	property bool shineAnimationEnabled: true
	property bool animationEnabled: true

	property real _normalizedRadiansFactor: (Math.PI/180) / (2*Math.PI)
	property real _maxRadius: width/2

	onProgressAngleChanged: {
		if (!progressAnimator.running) {
			progressAnimator.from = shader.progressAngle
			progressAnimator.to = gauge.progressAngle * _normalizedRadiansFactor
			progressAnimator.start()
		}
	}

	Timer {
		running: gauge.shineAnimationEnabled
		interval: Theme.animation.briefPage.centerGauge.shine.duration + (Theme.animation.briefPage.centerGauge.shine.duration * Theme.animation.briefPage.centerGauge.shine.pauseRatio)
		repeat: true
		onTriggered: {
			shineAnimator.duration = (gauge.progressAngle / gauge.endAngle) * Theme.animation.briefPage.centerGauge.shine.duration
			shineAnimator.from = 0.0
			shineAnimator.to = Math.min(gauge.endAngle, gauge.progressAngle+5) * _normalizedRadiansFactor
			shineAnimator.start()
		}
	}

	ShaderEffect {
		id: shader
		anchors.fill: parent
		fragmentShader: "shaders/circulargauge.frag.qsb"

		property color remainderColor: gauge.remainderColor
		property color progressColor: gauge.progressColor
		property color shineColor: gauge.shineColor
		// transform angles to radians and then normalize
		property real startAngle: gauge.startAngle * gauge._normalizedRadiansFactor
		property real endAngle: gauge.endAngle * gauge._normalizedRadiansFactor
		property real progressAngle: -1.0
		property real shineAngle: -1.0
		// transform radii to uv coords
		property real innerRadius: (gauge.radius - (gauge.strokeWidth/2)) / (gauge._maxRadius)
		property real radius: gauge.radius / (gauge._maxRadius)
		property real outerRadius: (gauge.radius + (gauge.strokeWidth/2)) / (gauge._maxRadius)
		// transform smoothing pixels to uv distance
		property real smoothing: gauge.smoothing / gauge._maxRadius
		property real clockwise: gauge.clockwise ? 1.0 : 0.0

		UniformAnimator {
			id: progressAnimator
			target: shader
			uniform: "progressAngle"
			duration: Theme.animation.progressArc.duration
			easing.type: Easing.InOutQuad
		}

		UniformAnimator {
			id: shineAnimator
			target: shader
			uniform: "shineAngle"
			easing.type: Easing.InQuad
			onRunningChanged: if (!running) shader.shineAngle = -1.0
		}
	}
}
