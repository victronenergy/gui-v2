/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	property alias text: titleLabel.text
	property alias textColor: titleLabel.color

	width: parent.width
	height: Theme.geometry_levelsPage_panel_header_height
	topLeftRadius: Theme.geometry_levelsPage_panel_radius
	topRightRadius: Theme.geometry_levelsPage_panel_radius

	Label {
		id: titleLabel

		x: Theme.geometry_levelsPage_panel_horizontalMargin
		width: parent.width - 2*x
		anchors.verticalCenter: parent.verticalCenter
		horizontalAlignment: Text.AlignHCenter

		font.pixelSize: Theme.font_size_caption
		elide: Text.ElideRight
	}
}
