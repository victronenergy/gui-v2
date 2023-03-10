/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListView {
	id: root

	property var listPage

	x: Theme.geometry.page.content.horizontalMargin
	width: !!parent ? parent.width - Theme.geometry.page.content.horizontalMargin : 0
	height: !!parent ? parent.height : 0
	topMargin: Theme.geometry.gradientList.topMargin
	bottomMargin: Theme.geometry.gradientList.bottomMargin
	rightMargin: Theme.geometry.page.content.horizontalMargin

	ViewGradient {
		anchors {
			bottom: root.bottom
			left: root.left
			right: root.right
		}
	}

	ScrollBar.vertical: ScrollBar {
		topPadding: Theme.geometry.gradientList.topMargin
		bottomPadding: Theme.geometry.gradientList.bottomMargin
	}
}
