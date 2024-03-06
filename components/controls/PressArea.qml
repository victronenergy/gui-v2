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

	onPressed: if (effectEnabled) pressEffect.start(mouseX/width, mouseY/height)
	onReleased: if (effectEnabled) pressEffect.stop()
	onCanceled: if (effectEnabled) pressEffect.stop()

	PressEffect {
		id: pressEffect
	}
}
