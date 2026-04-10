/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import jhofstee.nl.VTerm

Item {
	id: root
	signal finished(int ret)

	Terminal {
		anchors.fill: parent
		objectName: "terminal"
		focus: true

		// When started on a portrait screen, the terminal is drawn rotated.
		property list<QtObject> portrait: [
			Rotation {
				angle: 90
			},
			Translate {
				x: Screen.width
			}
		]
		transform: (Screen.width < Screen.height) ? portrait : undefined
		onFinished: ret => root.finished(ret)
	}
}
