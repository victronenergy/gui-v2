/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Rectangle {
	id: root
	signal finished(int ret)
	color: "black"

	Text {
		anchors {
			left: parent.left
			top: parent.top
			margins: 20
		}
		color: "white"
		text: "Press ALT-F1 to return to gui-v2"
	}

	Timer {
		interval: 10000
		running: true
		repeat: false
		onTriggered: root.finished(1)
	}
}
