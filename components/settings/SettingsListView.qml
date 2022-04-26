/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListView {
	id: root

	x: Theme.geometry.page.content.horizontalMargin
	width: parent.width - Theme.geometry.page.content.horizontalMargin
	height: parent.height
	topMargin: Theme.geometry.settingsPage.settingsList.topMargin
	bottomMargin: Theme.geometry.settingsPage.settingsList.bottomMargin
	rightMargin: Theme.geometry.page.content.horizontalMargin

	Rectangle {
		anchors {
			bottom: root.bottom
			left: root.left
			right: root.right
		}
		height: Theme.geometry.settingsPage.settingsList.gradient.height
		gradient: Gradient {
			GradientStop {
				position: Theme.geometry.settingsPage.settingsList.gradient.position1
				color: Theme.color.settingsPage.settingsList.gradient.color1
			}
			GradientStop {
				position: Theme.geometry.settingsPage.settingsList.gradient.position2
				color: Theme.color.settingsPage.settingsList.gradient.color2
			}
			GradientStop {
				position: Theme.geometry.settingsPage.settingsList.gradient.position3
				color: Theme.color.settingsPage.settingsList.gradient.color3
			}
		}
	}

	ScrollBar.vertical: ScrollBar {
		topPadding: Theme.geometry.settingsPage.settingsList.topMargin
		bottomPadding: Theme.geometry.settingsPage.settingsList.bottomMargin
	}
}
