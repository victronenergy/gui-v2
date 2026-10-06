/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

MouseArea {
	id: root

	property bool effectEnabled: true
	property real radius
	property color color: Qt.rgba(Theme.color_font_primary.r, Theme.color_font_primary.g, Theme.color_font_primary.b, 0.1)

	function _playEffect() {
		const fx = Global.pressEffect
		if (!fx) {
			return
		}
		if (fx.parent && fx.parent !== root) {
			fx.stop()
		}
		fx.parent = root
		fx.radius = root.radius
		fx.color = root.color
		fx.start(mouseX / width, mouseY / height)
	}

	function _stopEffect() {
		const fx = Global.pressEffect
		if (fx && fx.parent === root) {
			fx.stop()
		}
	}

	function _releaseEffect() {
		const fx = Global.pressEffect
		if (fx && fx.parent === root) {
			fx.stop()
			fx.parent = null
		}
	}

	onPressed: if (effectEnabled) root._playEffect()
	onReleased: if (effectEnabled) root._stopEffect()
	onCanceled: if (effectEnabled) root._stopEffect()
	Component.onDestruction: root._releaseEffect()
}
