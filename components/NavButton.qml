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

	font.pixelSize: Global.portraitMode ? Theme.font_size_tiny : Theme.font_size_body1

	color: down
		   ? Theme.color_navigationBar_button_on
		   : Theme.color_navigationBar_button_off
}
