import QtQuick
import Victron.VenusOS

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
