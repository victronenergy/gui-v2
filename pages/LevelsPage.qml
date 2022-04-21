/*!
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	TabBar {
		id: tabBar

		anchors {
			top: parent.top
			topMargin: PageManager.expandLayout ? -tabBar.height : 0
			horizontalCenter: parent.horizontalCenter
		}
		opacity: PageManager.interactivity === Enums.PageManager_InteractionMode_Interactive
				 || PageManager.interactivity === Enums.PageManager_InteractionMode_ExitIdleMode
				 ? 1.0
				 : 0.0

		Behavior on opacity { OpacityAnimator { duration: Theme.animation.page.idleOpacity.duration } }

		Behavior on anchors.topMargin {
			NumberAnimation { duration: Theme.animation.page.idleResize.duration; easing.type: Easing.InOutQuad }
		}

		model: ListModel {
			ListElement {
				//% "Tanks"
				text: QT_TRID_NOOP("levels_page_tanks")
			}
			ListElement {
				//% "Environment"
				text: QT_TRID_NOOP("levels_page_environment")
			}
		}

		// Remember currentIndex when returning to the Levels page
		currentIndex: PageManager.levelsTabIndex

		onCurrentIndexChanged: {
			// Load the Environments tab the first time it is required
			if (currentIndex === 1 && !environmentsTabLoader.active) {
				environmentsTabLoader.active = true
			}
			PageManager.levelsTabIndex = currentIndex
		}
	}

	TanksTab {
		id: tanksTab

		anchors {
			top: tabBar.bottom
			topMargin: PageManager.expandLayout
					   ? Theme.geometry.levelsPage.gaugesView.expanded.topMargin
					   : Theme.geometry.levelsPage.gaugesView.compact.topMargin
			bottom: parent.bottom
			bottomMargin: PageManager.expandLayout
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

		Behavior on x {
			enabled: tanksTab.animateModelChanges
			NumberAnimation { duration: Theme.animation.levelsPage.tanks.modelChangeResize.duration; easing.type: Easing.InOutQuad }
		}
		Behavior on anchors.topMargin {
			NumberAnimation { duration: Theme.animation.page.idleResize.duration; easing.type: Easing.InOutQuad }
		}
		Behavior on anchors.bottomMargin {
			NumberAnimation { duration: Theme.animation.page.idleResize.duration; easing.type: Easing.InOutQuad }
		}

		visible: tabBar.currentIndex === 0
	}

	Loader {
		id: environmentsTabLoader

		active: false
		visible: tabBar.currentIndex === 1

		anchors {
			top: tabBar.bottom
			topMargin: PageManager.expandLayout
					   ? Theme.geometry.levelsPage.gaugesView.expanded.topMargin
					   : Theme.geometry.levelsPage.gaugesView.compact.topMargin
			bottom: parent.bottom
			bottomMargin: PageManager.expandLayout
						  ? Theme.geometry.levelsPage.gaugesView.expanded.bottomMargin
						  : Theme.geometry.levelsPage.gaugesView.compact.bottomMargin
			left: parent.left
			right: parent.right
		}

		Behavior on anchors.topMargin {
			NumberAnimation { duration: Theme.animation.page.idleResize.duration; easing.type: Easing.InOutQuad }
		}
		Behavior on anchors.bottomMargin {
			NumberAnimation { duration: Theme.animation.page.idleResize.duration; easing.type: Easing.InOutQuad }
		}

		sourceComponent: EnvironmentTab { }
	}
}
