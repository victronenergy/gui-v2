/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	Label {
		anchors.centerIn: parent
		text: "OverviewPage placeholder"
	}

	Rectangle {
		color: "blue"
		width: 176
		height: 152
		x: 24
		y: 48
	}

	Rectangle {
		color: "blue"
		width: 240
		height: 152
		x: 280
		y: 48
	}

	Rectangle {
		Label { text: "Solar Yield"; anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter }
		color: "blue"
		width: 176
		height: 152
		x: 24
		y: 248
		MouseArea {
			anchors.fill: parent
			onClicked: PageManager.pushPage("qrc:/pages/SolarYieldPage.qml")
		}
	}

	Rectangle {
		color: "blue"
		width: 240
		height: 152
		x: 280
		y: 248
	}

	Rectangle {
		color: "blue"
		width: 176
		height: 352
		x: 600
		y: 48
	}

	
}
