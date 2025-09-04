/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {

	property alias highlightVisible: highlight.visible

	width: Theme.geometry_slider_indicator_width
	height: Theme.geometry_slider_indicator_height
	color: Theme.color_white
	radius: Theme.geometry_Slider_indicator_radius

	// Inverted width/height for how highlight expects layout
	SliderHandleHighlight {
		id: highlight
		anchors.centerIn: parent
		width: Theme.geometry_slider_indicator_height
		height: Theme.geometry_slider_indicator_width
	}
}
