/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Button {
	id: root

	icon.width: Theme.geometry.navigationBar.button.icon.width
	icon.height: Theme.geometry.navigationBar.button.icon.height
	spacing: Theme.geometry.navigationBar.button.spacing
	display: C.AbstractButton.TextUnderIcon

	color: down
		   ? Theme.color.navigationBar.button.on
		   : Theme.color.navigationBar.button.off
}
