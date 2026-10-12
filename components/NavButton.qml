/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	icon.width: Theme.geometry_shared_32_32_24
	icon.height: Theme.geometry_shared_32_32_24
	spacing: Theme.geometry_size_4
	display: Button.TextUnderIcon
	radius: 0
	color: down
		   ? Theme.color_navigationBar_button_on
		   : Theme.color_navigationBar_button_off
	backgroundColor: "transparent"
	font.pixelSize: Theme.font_navigationButton_size

}
