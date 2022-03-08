/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property real power: NaN

	property Timer demoTimer: Timer {
		running: true
		interval: 1000
		repeat: true

		onTriggered: {
			root.power = 500 + Math.floor(Math.random() * 100)
		}
	}
}
