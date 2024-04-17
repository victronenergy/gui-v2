/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Rectangle {
	id: root

	property string title

	property int leftButton: VenusOS.StatusBar_LeftButton_None
	property int rightButton: VenusOS.StatusBar_RightButton_None
	property alias rightSideRow: rightSideRow

	property bool animationEnabled

	signal leftButtonClicked()
	signal rightButtonClicked()

	width: parent.width
	height: Theme.geometry_statusBar_height
	opacity: 0

	SequentialAnimation {
		running: !Global.splashScreenVisible && animationEnabled

		PauseAnimation {
			duration: Theme.animation_statusBar_initialize_delayedStart_duration
		}
		OpacityAnimator {
			target: root
			from: 0.0
			to: 1.0
			duration: Theme.animation_statusBar_initialize_fade_duration
		}
	}

	component StatusBarButton : Button {
		radius: 0
		width: parent.height
		height: parent.height
		backgroundColor: "transparent"  // don't show background when disabled
		display: C.AbstractButton.IconOnly
		color: Theme.color_ok
		opacity: enabled ? 1.0 : 0.0
		Behavior on opacity {
			enabled: root.animationEnabled
			OpacityAnimator {
				duration: Theme.animation_page_idleOpacity_duration
			}
		}
	}

	StatusBarButton {
		id: leftButton

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_statusBar_horizontalMargin
			verticalCenter: parent.verticalCenter
		}
		icon.source: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsInactive
					 ? "qrc:/images/icon_controls_off_32.svg"
					 : root.leftButton === VenusOS.StatusBar_LeftButton_ControlsActive
					   ? "qrc:/images/icon_controls_on_32.svg"
					   : "qrc:/images/icon_back_32.svg"

		enabled: !!Global.pageManager
				&& Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
				&& root.leftButton != VenusOS.StatusBar_LeftButton_None

		onClicked: root.leftButtonClicked()
	}

	Label {
		id: clockLabel
		anchors.centerIn: parent
		font.pixelSize: 22
		text: root.title.length > 0 ? root.title : ClockTime.currentTime
	}

	Row {
		id: rightSideRow
		anchors {
			right: rightButtonRow.left
			rightMargin: Theme.geometry_statusBar_rightSideRow_horizontalMargin
			verticalCenter: parent.verticalCenter
		}
	}

	Row {
		id: rightButtonRow

		height: parent.height
		anchors {
			right: parent.right
			rightMargin: Theme.geometry_statusBar_horizontalMargin
		}

		StatusBarButton {
			enabled: !!Global.pageManager
					&& Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
					&& root.rightButton != VenusOS.StatusBar_RightButton_None

			icon.source: root.rightButton === VenusOS.StatusBar_RightButton_SidePanelActive
					? "qrc:/images/icon_sidepanel_on_32.svg"
					: root.rightButton === VenusOS.StatusBar_RightButton_SidePanelInactive
						? "qrc:/images/icon_sidepanel_off_32.svg"
						: root.rightButton === VenusOS.StatusBar_RightButton_Add
						  ? "qrc:/images/icon_plus.svg"
						  : root.rightButton === VenusOS.StatusBar_RightButton_Refresh
							? "qrc:/images/icon_refresh_32.svg"
							: ""

			onClicked: root.rightButtonClicked()
		}

		StatusBarButton {
			icon.source: "qrc:/images/icon_screen_sleep_32.svg"
			visible: !!Global.screenBlanker && Global.screenBlanker.supported && Global.screenBlanker.enabled
			enabled: !!Global.pageManager
					 && Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
			onClicked: Global.screenBlanker.setDisplayOff()
		}
	}
}
