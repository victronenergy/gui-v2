/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Button {
	leftPadding: Theme.geometry_listItemButton_horizontalPadding
	rightPadding: Theme.geometry_listItemButton_horizontalPadding
	implicitHeight: Theme.geometry_listItemButton_height
	flat: !enabled
	font.pixelSize: Theme.font_size_body2
}
