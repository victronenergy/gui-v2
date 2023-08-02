/*!
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	fullScreenWhenIdle: true

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
			OpacityAnimator { duration: Theme.animation.page.idleOpacity.duration }
		}

		Behavior on anchors.topMargin {
			enabled: root.isCurrentPage
			NumberAnimation { duration: Theme.animation.page.idleResize.duration; easing.type: Easing.InOutQuad }
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
					   ? Theme.geometry.levelsPage.gaugesView.expanded.topMargin
					   : Theme.geometry.levelsPage.gaugesView.compact.topMargin
			bottom: parent.bottom
			bottomMargin: (!!Global.pageManager && Global.pageManager.expandLayout)
						  ? Theme.geometry.levelsPage.gaugesView.expanded.bottomMargin
						  : Theme.geometry.levelsPage.gaugesView.compact.bottomMargin
		}
		x: contentWidth > width
				? Theme.geometry.levelsPage.gaugesView.horizontalMargin
				: parent.width/2 - contentWidth / 2
		width: parent.width
		rightMargin: contentWidth > width
					 ? 2*Theme.geometry.levelsPage.gaugesView.horizontalMargin
					 : 0
		animationEnabled: root.animationEnabled

		Behavior on x {
			enabled: root.isCurrentPage && tanksTab.animateModelChanges
			NumberAnimation { duration: Theme.animation.levelsPage.tanks.modelChangeResize.duration; easing.type: Easing.InOutQuad }
		}
		Behavior on anchors.topMargin {
			enabled: root.isCurrentPage
			NumberAnimation { duration: Theme.animation.page.idleResize.duration; easing.type: Easing.InOutQuad }
		}
		Behavior on anchors.bottomMargin {
			enabled: root.isCurrentPage
			NumberAnimation { duration: Theme.animation.page.idleResize.duration; easing.type: Easing.InOutQuad }
		}

		visible: tabBar.currentIndex === 0
	}

	EnvironmentTab {
		id: environmentTab

		anchors {
			top: tabBar.bottom
			topMargin: (!!Global.pageManager && Global.pageManager.expandLayout)
					   ? Theme.geometry.levelsPage.gaugesView.expanded.topMargin
					   : Theme.geometry.levelsPage.gaugesView.compact.topMargin
			bottom: parent.bottom
			bottomMargin: (!!Global.pageManager && Global.pageManager.expandLayout)
						  ? Theme.geometry.levelsPage.gaugesView.expanded.bottomMargin
						  : Theme.geometry.levelsPage.gaugesView.compact.bottomMargin
			left: parent.left
			right: parent.right
		}
		animationEnabled: root.animationEnabled

		Behavior on anchors.topMargin {
			enabled: root.isCurrentPage
			NumberAnimation { duration: Theme.animation.page.idleResize.duration; easing.type: Easing.InOutQuad }
		}
		Behavior on anchors.bottomMargin {
			enabled: root.isCurrentPage
			NumberAnimation { duration: Theme.animation.page.idleResize.duration; easing.type: Easing.InOutQuad }
		}

		visible: tabBar.currentIndex === 1
	}
}
