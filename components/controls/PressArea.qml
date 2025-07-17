/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

MouseArea {
	id: root

	property bool effectEnabled: true
	property alias radius: pressEffect.radius
	property alias color: pressEffect.color

	onPressed: if (pressEffect.active) pressEffect.item.start(mouseX/width, mouseY/height)
	onReleased: if (pressEffect.active) pressEffect.item.stop()
	onCanceled: if (pressEffect.active) pressEffect.item.stop()

	Loader {
		id: pressEffect
		anchors.fill: parent
		active: Qt.platform.os === "wasm" && root.effectEnabled
		source: "qrc:/qt/qml/Victron/VenusOS/components/controls/PressEffect.qml"

		property real radius
		property color color

		onItemChanged: {
			if (item) {
				item.radius = Qt.binding(function() { return pressEffect.radius })
				item.color = Qt.binding(function() { return pressEffect.color })
			}
		}
	}
}
