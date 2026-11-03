/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// Counts while its loader is active. The nav wrapper must not load this page
// until the page is current.
Item {
	id: root

	property int ticks: 0

	Timer {
		interval: 200
		repeat: true
		running: true
		onTriggered: root.ticks++
	}
}
