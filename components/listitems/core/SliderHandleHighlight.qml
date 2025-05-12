/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A highlight frame with left/right arrow indicators on either side.
*/
EditFrame {
	property Item handle

	width: handle.width
	height: handle.height
	y: -Theme.geometry_switch_indicator_shadowOffset
	rotation: 90
	arrowHintsVisible: true
}
