/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property bool active
	visible: active && timer.running && (!Global.pageManager || !Global.pageManager.expandLayout)
	property real margin: Theme.geometry_key_navigation_border_margin

	Timer {
		id: timer
		running: active
		interval: 10000
	}

	Rectangle {
		id: highlightMargin
		anchors {
			fill: parent
			margins: Theme.geometry_key_navigation_highlight_margin + root.margin
		}
		color: "#72B84C"
		opacity: 0.3
		radius: 4
	}

	BorderImage {
		anchors {
			fill: parent
			margins: root.margin
		}
		source: "qrc:/images/key-navigation-highlight.svg"
		border {
			left: Theme.geometry_key_navigation_border_corner_size
			right: Theme.geometry_key_navigation_border_corner_size
			top: Theme.geometry_key_navigation_border_corner_size
			bottom: Theme.geometry_key_navigation_border_corner_size
		}
	}
}
