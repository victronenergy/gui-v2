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
	leftPadding: infoIcon.x + infoIcon.width + Theme.geometry_listItem_content_spacing

	CP.IconImage {
		id: infoIcon

		// Apply inset+padding as for ListItem.
		x: (root.flat ? 0 : Theme.geometry_page_content_horizontalMargin)
		   + (root.flat ? Theme.geometry_listItem_flat_content_horizontalMargin
			   : Theme.geometry_listItem_content_horizontalMargin)
		y: root.topPadding + (infoFontMetrics.boundingRect("A").height - height)/2
		source: "qrc:/images/information.svg"
		color: root.color
	}

	FontMetrics {
		id: infoFontMetrics
		font: root.font
	}
}
