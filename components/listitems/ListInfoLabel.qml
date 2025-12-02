/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

PrimaryListLabel {
	id: root

	property bool flat

	font.pixelSize: Theme.font_size_caption
	color: Theme.color_font_disabled
	leftPadding: infoIcon.x + infoIcon.width + infoIcon.x/2

	CP.IconImage {
		id: infoIcon

		x: root.flat ? Theme.geometry_listItem_flat_content_horizontalMargin : Theme.geometry_listItem_content_horizontalMargin
		y: root.topPadding + (infoFontMetrics.boundingRect("A").height - height)/2
		source: "qrc:/images/information.svg"
		color: root.color
	}

	FontMetrics {
		id: infoFontMetrics
		font: root.font
	}
}
