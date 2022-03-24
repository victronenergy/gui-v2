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
			topMargin: PageManager.interactivity === PageManager.InteractionMode.Idle ? -tabBar.height : 0
			horizontalCenter: parent.horizontalCenter
		}

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

		opacity: PageManager.interactivity === PageManager.InteractionMode.Interactive
			 || PageManager.interactivity === PageManager.InteractionMode.ExitIdleMode ? 1.0 : 0.0
		Behavior on opacity { OpacityAnimator { duration: Theme.animation.page.idleOpacity.duration } }

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
			topMargin: PageManager.interactivity === PageManager.InteractionMode.Idle
					   ? Theme.geometry.levelsPage.gaugesView.fullScreen.topMargin
					   : Theme.geometry.levelsPage.gaugesView.interactive.topMargin
			bottom: parent.bottom
			bottomMargin: PageManager.interactivity === PageManager.InteractionMode.Idle
						  ? Theme.geometry.levelsPage.gaugesView.fullScreen.bottomMargin
						  : Theme.geometry.levelsPage.gaugesView.interactive.bottomMargin
			left: anchorCenter ? undefined : parent.left
			leftMargin: anchorCenter ? 0 : Theme.geometry.levelsPage.gaugesView.leftMargin
			horizontalCenter: anchorCenter ? parent.horizontalCenter : undefined
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
			topMargin: PageManager.interactivity === PageManager.InteractionMode.Idle
					   ? Theme.geometry.levelsPage.gaugesView.fullScreen.topMargin
					   : Theme.geometry.levelsPage.gaugesView.interactive.topMargin
			bottom: parent.bottom
			bottomMargin: PageManager.interactivity === PageManager.InteractionMode.Idle
						  ? Theme.geometry.levelsPage.gaugesView.fullScreen.bottomMargin
						  : Theme.geometry.levelsPage.gaugesView.interactive.bottomMargin
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
