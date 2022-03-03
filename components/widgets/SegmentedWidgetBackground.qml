/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	property alias segments: separatorRepeater.model

	width: Theme.geometry.overviewPage.widget.input.width
	height: segments && segments.length > 1 && visible
			? segments[segments.length-1].y + segments[segments.length-1].height
			: 0

	radius: Theme.geometry.overviewPage.widget.radius
	border.width: Theme.geometry.overviewPage.widget.border.width
	border.color: Theme.color.overviewPage.widget.border
	color: Theme.color.overviewPage.widget.background

	Repeater {
		id: separatorRepeater

		model: null

		Rectangle {
			visible: model.index > 0
			y: modelData.y
			width: parent.width
			height: Theme.geometry.overviewPage.widget.border.width
			color: Theme.color.overviewPage.widget.border
		}
	}
}
