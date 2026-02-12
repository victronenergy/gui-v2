/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Button {
	width: Math.min(implicitWidth, Theme.geometry_listItem_width / 2)
	leftPadding: Theme.geometry_listItemButton_horizontalPadding
	rightPadding: Theme.geometry_listItemButton_horizontalPadding
	font.pixelSize: Theme.font_size_body2
	flat: false
}
