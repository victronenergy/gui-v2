/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	icon.width: Theme.geometry_navigationBar_button_icon_width
	icon.height: Theme.geometry_navigationBar_button_icon_height
	spacing: Theme.geometry_navigationBar_button_spacing
	display: Button.TextUnderIcon
	radius: 0
	extent: 0 // TODO: this shouldn't be necessary
	objectName: text + "NavButton" // TODO: remove

	color: down
		   ? Theme.color_navigationBar_button_on
		   : Theme.color_navigationBar_button_off
}
