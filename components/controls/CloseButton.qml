/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

IconButton {
	width: icon.sourceSize.width + (2 * Theme.geometry_closeButton_margins)
	height: icon.sourceSize.height + (2 * Theme.geometry_closeButton_margins)
	icon.color: Theme.color_ok
	icon.source: "qrc:/images/icon_close_32.svg"
}
