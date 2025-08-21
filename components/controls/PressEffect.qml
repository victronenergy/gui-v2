/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.VenusOS.Shaders

BasePressEffect {
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

	anchors.fill: parent
	color: Qt.rgba(Theme.color_font_primary.r, Theme.color_font_primary.g, Theme.color_font_primary.b, 0.1)
	opacity: 0.0

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

		// TODO: Migrate to non-blocking UniformAnimator once QTBUG-124152 has been fixed
		NumberAnimation {
			target: shaderEffect
			property: "progress"
			from: 0.0
			to: 1.0
			duration: 400
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

		// TODO: Migrate to non-blocking UniformAnimator once QTBUG-124152 has been fixed
		NumberAnimation {
			target: shaderEffect
			property: "progress"
			from: shaderEffect.progress
			to: 1.0
			duration: 300
			easing.type: Easing.InSine
		}
	}
}
