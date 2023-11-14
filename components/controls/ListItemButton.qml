/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
