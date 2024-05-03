/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Button {
	id: root

	icon.width: Theme.geometry_navigationBar_button_icon_width
	icon.height: Theme.geometry_navigationBar_button_icon_height
	spacing: Theme.geometry_navigationBar_button_spacing
	display: C.AbstractButton.TextUnderIcon
	radius: 0

	color: down
		   ? Theme.color_navigationBar_button_on
		   : Theme.color_navigationBar_button_off

	KeyNavigationHighlight {
		anchors.fill: parent
		active: root.activeFocus
	}
}
