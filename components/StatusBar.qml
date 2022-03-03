/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Item {
	id: root

	property bool controlsActive
	property bool controlsVisible: true
	property bool sidePanelActive
	property bool sidePanelVisible

	width: parent.width
	height: Theme.geometry.statusBar.height

	Button {
		id: controlsButton

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.statusBar.horizontalMargin
			verticalCenter: parent.verticalCenter
		}

		height: Theme.geometry.statusBar.button.height
		width: Theme.geometry.statusBar.button.width
		display: C.AbstractButton.IconOnly
		color: Theme.color.ok
		icon.source: root.controlsActive ? "qrc:/images/controls-toggled.svg" : "qrc:/images/controls.svg"
		icon.width: 28
		icon.height: 28
		onClicked: root.controlsActive = !root.controlsActive

		enabled: controlsVisible
		opacity: controlsVisible ? 1.0 : 0.0
		Behavior on opacity { OpacityAnimator { duration: Theme.animation.statusBar.sidePanelButton.fade.duration } }
	}

	Label {
		id: clockLabel
		anchors.centerIn: parent
		font.pixelSize: 22
		text: clockTimer.timeString
		Timer {
			id: clockTimer
			interval: 1000 // 1 second
			running: root.opacity > 0.0
			property string timeString: "00:00"
			onTriggered: {
				var currDate = new Date()
				var hours = currDate.getHours()
				var mins = currDate.getMinutes()
				if (hours < 10) hours = "0" + hours
				if (mins < 10)   mins = "0" + mins
				timeString = hours + ":" + mins
			}
		}
	}

	Button {
		id: sidePanelButton

		anchors {
			right: parent.right
			rightMargin: Theme.geometry.statusBar.horizontalMargin
			verticalCenter: parent.verticalCenter
		}

		opacity: sidePanelVisible ? 1.0 : 0.0
		Behavior on opacity { OpacityAnimator { duration: Theme.animation.statusBar.sidePanelButton.fade.duration } }

		height: Theme.geometry.statusBar.button.height
		width: Theme.geometry.statusBar.button.width
		display: C.AbstractButton.IconOnly
		color: Theme.color.ok
		icon.source: root.state === '' ? "qrc:/images/panel-toggle.svg" : "qrc:/images/panel-toggled.svg"
		icon.width: 28
		icon.height: 20
		onClicked: root.sidePanelActive = !root.sidePanelActive
	}
}
