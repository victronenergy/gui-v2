/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

SwipeViewPage {
	id: root

	// Used by StartPageConfiguration when this is the start page.
	property alias currentTabIndex: tabBar.currentIndex

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	fullScreenWhenIdle: true
	//% "Levels"
	navButtonText: qsTrId("nav_levels")
	navButtonIcon: "qrc:/images/levels.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/LevelsPage.qml"

	// Gauges may overflow into previous/next pages in the SwipeView, so clip the gauge ListView
	// to the page bounds.
	clip: tanksTab.contentWidth > tanksTab.width || environmentTab.contentWidth > environmentTab.width

	TabBar {
		id: tabBar

		anchors {
			top: parent.top
			topMargin: Global.pageManager?.expandLayout ? -tabBar.height : 0
			horizontalCenter: parent.horizontalCenter
		}

		opacity: Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive
				 || Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_ExitIdleMode
				 ? 1.0
				 : 0.0

		Behavior on opacity {
			enabled: root.isCurrentPage
			OpacityAnimator { duration: Theme.animation_page_idleOpacity_duration }
		}

		Behavior on anchors.topMargin {
			enabled: root.isCurrentPage
			NumberAnimation { duration: Theme.animation_page_idleResize_duration; easing.type: Easing.InOutQuad }
		}

		model: [
			//% "Tanks"
			{ value: qsTrId("levels_page_tanks"), enabled: Global.tanks.totalTankCount > 0 },
			//% "Environment"
			{ value: qsTrId("levels_page_environment"), enabled: Global.environmentInputs.model.count > 0 }
		]

		// Prefer a tab that is enabled.
		currentIndex: model[0].enabled || !model[1].enabled ? 0 : 1
	}

	TanksTab {
		id: tanksTab

		anchors {
			top: tabBar.bottom
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		animationEnabled: root.animationEnabled
		visible: tabBar.currentIndex === 0
	}

	EnvironmentTab {
		id: environmentTab

		anchors {
			top: tabBar.bottom
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		animationEnabled: root.animationEnabled
		visible: tabBar.currentIndex === 1
	}

	// Show gradients on the left/right edges to indicate the page bounds
	ViewGradient {
		x: -(width / 2) + (height / 2)
		rotation: 90
		visible: root.clip
	}
	ViewGradient {
		x: (width / 2) - (height / 2)
		rotation: 270
		visible: root.clip
	}
}
