/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property bool active
	property real borderMargin

	visible: active && (!Global.pageManager || !Global.pageManager.expandLayout)

	Rectangle {
		id: highlightMargin
		anchors {
			fill: parent
			margins: Theme.geometry_focus_highlight_margin + root.borderMargin
		}
		color: Theme.color_focus_highlight
		opacity: 0.3
		radius: Theme.geometry_focus_highlight_radius
	}

	BorderImage {
		anchors {
			fill: parent
			margins: root.borderMargin
		}
		source: "qrc:/images/key-navigation-highlight.svg"
		border {
			left: Theme.geometry_focus_border_corner_size
			right: Theme.geometry_focus_border_corner_size
			top: Theme.geometry_focus_border_corner_size
			bottom: Theme.geometry_focus_border_corner_size
		}
	}
}
