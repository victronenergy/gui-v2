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
	activeFocusOnTab: true
	//% "Levels"
	navButtonText: qsTrId("nav_levels")
	navButtonIcon: "qrc:/images/levels.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/LevelsPage.qml"

	// Gauges may overflow into previous/next pages in the SwipeView, so clip the gauge ListView
	// to the page bounds.
	clip: tanksTab.contentWidth > tanksTab.width || environmentTab.contentWidth > environmentTab.width

	onActiveFocusChanged: {
		if (root.view.focusEdgeHint === Qt.TopEdge) {
			tabBar.focus = true
		} else if (root.view.focusEdgeHint === Qt.BottomEdge) {
			tabsFocusScope.focus = true
		}
	}

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
			{ value: qsTrId("levels_page_tanks"), enabled: tanksTab.enabled },
			//% "Environment"
			{ value: qsTrId("levels_page_environment"), enabled: environmentTab.enabled }
		]

		// Prefer a tab that is enabled.
		currentIndex: tanksTab.enabled || !environmentTab.enabled ? 0 : 1
		KeyNavigation.down: tabsFocusScope
	}

	FocusScope {
		id: tabsFocusScope
		anchors {
			top: tabBar.bottom
			topMargin: Global.pageManager?.expandLayout
					? Theme.geometry_levelsPage_gaugesView_expanded_topMargin
					: Theme.geometry_levelsPage_gaugesView_compact_topMargin
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}

		Behavior on anchors.topMargin {
			enabled: root.animationEnabled
			NumberAnimation { duration: Theme.animation_page_idleResize_duration; easing.type: Easing.InOutQuad }
		}

		TanksTab {
			id: tanksTab

			anchors.fill: parent
			animationEnabled: root.animationEnabled
			enabled: Global.tanks.totalTankCount > 0
			visible: tabBar.currentIndex === 0
			focus: visible
		}

		EnvironmentTab {
			id: environmentTab

			anchors.fill: parent
			animationEnabled: root.animationEnabled
			enabled: Global.environmentInputs.model.count > 0
			visible: tabBar.currentIndex === 1
			focus: visible
		}
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
