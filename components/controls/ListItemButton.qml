/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Button {
	leftPadding: Theme.geometry.listItemButton.horizontalPadding
	rightPadding: Theme.geometry.listItemButton.horizontalPadding
	implicitHeight: Theme.geometry.listItemButton.height
	flat: !enabled
	font.pixelSize: Theme.font.size.body2
}
