/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property real power: NaN
	onPowerChanged: Utils.updateMaximumValue("system.dc.power", power)

	property Timer demoTimer: Timer {
		running: true
		interval: 1000
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			root.power = 500 + Math.floor(Math.random() * 100)
		}
	}
}
