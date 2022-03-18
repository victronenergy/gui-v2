/*!
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	LevelsPageButtonRow {
		id: buttons

		anchors {
			top: parent.top
			topMargin: tanksTab._interactive ? 0 : -buttons.height
			horizontalCenter: parent.horizontalCenter
		}
	}

	TanksTab {
		id: tanksTab

		anchors {
			top: buttons.bottom
			topMargin: tanksTab._interactive ? Theme.geometry.levelsPage.gaugesView.interactive.topMargin : Theme.geometry.levelsPage.gaugesView.fullScreen.topMargin
			bottom: parent.bottom
			bottomMargin: tanksTab._interactive ? Theme.geometry.levelsPage.gaugesView.interactive.bottomMargin : Theme.geometry.levelsPage.gaugesView.fullScreen.bottomMargin
			left: anchorCenter ? undefined : parent.left
			leftMargin: anchorCenter ? 0 : Theme.geometry.levelsPage.gaugesView.leftMargin
			horizontalCenter: anchorCenter ? parent.horizontalCenter : undefined
		}
	}

	MouseArea {
		id: idleModeMouseArea
		width: root.width
		height: root.height
		enabled: PageManager.interactivity === PageManager.InteractionMode.Idle
		onClicked: PageManager.interactivity = PageManager.InteractionMode.ExitIdleMode
	}
}
