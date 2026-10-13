/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

Rectangle {
	property alias highlightVisible: highlight.visible
	property alias handle: highlight.handle

	width: Theme.geometry_size_4
	height: Theme.geometry_size_28
	color: Theme.color_white
	radius: Theme.geometry_size_2

	// Inverted width/height for how highlight expects layout
	SliderHandleHighlight {
		id: highlight
		anchors.centerIn: parent
		width: Theme.geometry_size_28
		height: Theme.geometry_size_4
	}
}
