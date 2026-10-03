/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Label {
	height: text.length > 0 ? implicitHeight : 0
	font.pixelSize: Theme.font_listItem_caption_size
	lineHeight: Theme.font_listItem_caption_lineHeight
	lineHeightMode: Text.FixedHeight
	color: Theme.color_font_secondary
	wrapMode: Text.Wrap
	verticalAlignment: Text.AlignVCenter
}

