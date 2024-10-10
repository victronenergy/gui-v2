/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

SwipeViewPage {
	id: root

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	//% "Levels"
	navButtonText: qsTrId("nav_levels")
	navButtonIcon: "qrc:/images/levels.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/LevelsPage.qml"

	// Gauges may overflow into previous/next pages in the SwipeView, so clip the gauge ListView
	// to the page bounds.
	clip: tanksTab.contentWidth > tanksTab.width || environmentTab.contentWidth > environmentTab.width

	TabBar {
		id: tabBar

		// Prefer a tab that is enabled.
		property int _preferredIndex: model[0].enabled || !model[1].enabled ? 0 : 1

		anchors {
			top: parent.top
			topMargin: (!!Global.pageManager && Global.pageManager.expandLayout) ? -tabBar.height : 0
			horizontalCenter: parent.horizontalCenter
		}

		opacity: (!!Global.pageManager && (Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
				 || Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_ExitIdleMode))
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

		currentIndex: _preferredIndex
		onCurrentIndexChanged: _preferredIndex = currentIndex   // once user selects a tab, don't use the default index anymore
	}

	TanksTab {
		id: tanksTab

		anchors {
			top: tabBar.bottom
			topMargin: (!!Global.pageManager && Global.pageManager.expandLayout)
					   ? Theme.geometry_levelsPage_gaugesView_expanded_topMargin
					   : Theme.geometry_levelsPage_gaugesView_compact_topMargin
			bottom: parent.bottom
			bottomMargin: (!!Global.pageManager && Global.pageManager.expandLayout)
						  ? Theme.geometry_levelsPage_gaugesView_expanded_bottomMargin
						  : Theme.geometry_levelsPage_gaugesView_compact_bottomMargin
		}
		x: contentWidth > width
				? Theme.geometry_levelsPage_gaugesView_horizontalMargin
				: parent.width/2 - contentWidth / 2
		width: parent.width
		rightMargin: contentWidth > width
					 ? 2*Theme.geometry_levelsPage_gaugesView_horizontalMargin
					 : 0
		animationEnabled: root.animationEnabled

		Behavior on x {
			enabled: root.isCurrentPage && tanksTab.animateModelChanges
			NumberAnimation { duration: Theme.animation_levelsPage_tanks_modelChangeResize_duration; easing.type: Easing.InOutQuad }
		}
		Behavior on anchors.topMargin {
			enabled: root.isCurrentPage
			NumberAnimation { duration: Theme.animation_page_idleResize_duration; easing.type: Easing.InOutQuad }
		}
		Behavior on anchors.bottomMargin {
			enabled: root.isCurrentPage
			NumberAnimation { duration: Theme.animation_page_idleResize_duration; easing.type: Easing.InOutQuad }
		}

		visible: tabBar.currentIndex === 0
	}

	EnvironmentTab {
		id: environmentTab

		anchors {
			top: tabBar.bottom
			topMargin: (!!Global.pageManager && Global.pageManager.expandLayout)
					   ? Theme.geometry_levelsPage_gaugesView_expanded_topMargin
					   : Theme.geometry_levelsPage_gaugesView_compact_topMargin
			bottom: parent.bottom
			bottomMargin: (!!Global.pageManager && Global.pageManager.expandLayout)
						  ? Theme.geometry_levelsPage_gaugesView_expanded_bottomMargin
						  : Theme.geometry_levelsPage_gaugesView_compact_bottomMargin
			left: parent.left
			right: parent.right
		}
		animationEnabled: root.animationEnabled

		Behavior on anchors.topMargin {
			enabled: root.isCurrentPage
			NumberAnimation { duration: Theme.animation_page_idleResize_duration; easing.type: Easing.InOutQuad }
		}
		Behavior on anchors.bottomMargin {
			enabled: root.isCurrentPage
			NumberAnimation { duration: Theme.animation_page_idleResize_duration; easing.type: Easing.InOutQuad }
		}

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
