/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ShaderEffect {
	id: shaderEffect

	function start(x, y) {
		shaderEffect.touchPos = Qt.point(x, y)
		releaseEffect.stop()
		pressEffect.start()
		_stopPending = false
	}

	function stop() {
		if (!pressEffect.running) {
			releaseEffect.start()
		} else {
			_stopPending = true
		}
	}

	property bool _stopPending
	property real radius
	property real progress
	property point touchPos
	property real aspectRatio: height > 0 ? width/height : 1.0
	property real radiusRatio: height > 0 ? root.radius/height : 0.0
	property color color: Qt.rgba(Theme.color_font_primary.r, Theme.color_font_primary.g, Theme.color_font_primary.b, 0.1)

	opacity: 0.0
	anchors.fill: parent
	fragmentShader:  "qrc:/components/controls/presseffect.frag.qsb"

	ParallelAnimation {
		id: pressEffect

		onStopped: if (_stopPending) releaseEffect.start()

		OpacityAnimator {
			target: shaderEffect
			from: 0.0
			to: 1.0
			duration: 400
			easing.type: Easing.OutSine
		}

		// Disable UniformAnimator on WebAssembly due to QTBUG-124152
		UniformAnimator {
			target: shaderEffect
			uniform: "progress"
			from: 0.0
			to: 1.0
			duration: Qt.platform.os !== "wasm" ? 400 : 0
			easing.type: Easing.OutSine
		}
		NumberAnimation {
			target: shaderEffect
			property: "progress"
			from: 0.0
			to: 1.0
			duration: Qt.platform.os === "wasm" ? 400 : 0
			easing.type: Easing.OutSine
		}
	}

	ParallelAnimation {
		id: releaseEffect

		OpacityAnimator {
			target: shaderEffect
			from: 1.0
			to: 0.0
			duration: 300
			easing.type: Easing.InSine
		}

		// Disable UniformAnimator on WebAssembly due to QTBUG-124152
		UniformAnimator {
			target: shaderEffect
			uniform: "progress"
			from: shaderEffect.progress
			to: 1.0
			duration: Qt.platform.os !== "wasm" ? 300 : 0
			easing.type: Easing.InSine
		}

		NumberAnimation {
			target: shaderEffect
			property: "progress"
			from: shaderEffect.progress
			to: 1.0
			duration: Qt.platform.os === "wasm" ? 300 : 0
			easing.type: Easing.InSine
		}
	}
}
