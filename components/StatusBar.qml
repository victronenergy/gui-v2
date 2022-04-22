/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Item {
	id: root

	property string title
	property int navigationButton: VenusOS.StatusBar_NavigationButtonStyle_ControlsInactive
	property alias navigationButtonEnabled: navigationButton.enabled
	property bool sidePanelActive
	property alias sidePanelButtonEnabled: sidePanelButton.enabled
	property bool animationEnabled: true

	signal navigationButtonClicked()

	width: parent.width
	height: Theme.geometry.statusBar.height

	Button {
		id: navigationButton

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.statusBar.horizontalMargin
			verticalCenter: parent.verticalCenter
		}
		width: Theme.geometry.statusBar.button.width
		height: Theme.geometry.statusBar.button.height
		icon.width: Theme.geometry.statusBar.button.icon.width
		icon.height: Theme.geometry.statusBar.button.icon.height
		display: C.AbstractButton.IconOnly
		color: Theme.color.ok
		icon.source: root.navigationButton === VenusOS.StatusBar_NavigationButtonStyle_ControlsInactive
					 ? "qrc:/images/icon_controls_off_32.svg"
					 : root.navigationButton === VenusOS.StatusBar_NavigationButtonStyle_ControlsActive
					   ? "qrc:/images/icon_controls_on_32.svg"
					   : "qrc:/images/icon_back_32.svg"

		opacity: enabled ? 1.0 : 0.0
		Behavior on opacity {
			enabled: root.animationEnabled
			OpacityAnimator { duration: Theme.animation.page.idleOpacity.duration; onRunningChanged: console.log("StatusBar 1: animatorRunning:", running)
			}
		}

		onClicked: root.navigationButtonClicked()
	}

	Label {
		id: clockLabel
		anchors.centerIn: parent
		font.pixelSize: 22
		text: root.title.length > 0 ? root.title : clockTimer.timeString

		Timer {
			id: clockTimer
			interval: 1000 // 1 second
			running: root.opacity > 0.0 && root.title.length === 0
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

		opacity: enabled ? 1.0 : 0.0
		Behavior on opacity {
			enabled: root.animationEnabled && tanksTab && tanksTab.animateModelChanges
			OpacityAnimator {
				duration: Theme.animation.page.idleOpacity.duration
				onRunningChanged: console.log("StatusBar2: animatorRunning:", running)
			}
		}

		width: Theme.geometry.statusBar.button.width
		height: Theme.geometry.statusBar.button.height
		icon.width: Theme.geometry.statusBar.button.icon.width
		icon.height: Theme.geometry.statusBar.button.icon.height
		display: C.AbstractButton.IconOnly
		color: Theme.color.ok
		backgroundColor: "transparent"
		icon.source: root.sidePanelActive
					 ? "qrc:/images/icon_sidepanel_on_32.svg"
					 : "qrc:/images/icon_sidepanel_off_32.svg"
		onClicked: root.sidePanelActive = !root.sidePanelActive
	}
}
