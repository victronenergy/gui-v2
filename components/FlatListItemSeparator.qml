/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	// ListItem has built-in spacing below each item (Theme.geometry_gradientList_spacing), so add
	// this spacing below each separator to balance out the space between successful flat ListItems.
	implicitWidth: parent ? parent.width : 0
	implicitHeight: bar.height + Theme.geometry_gradientList_spacing

	SeparatorBar {
		id: bar

		x: Theme.geometry_separatorBar_horizontalMargin
		width: parent.width - (2 * Theme.geometry_separatorBar_horizontalMargin)
		height: Theme.geometry_separatorBar_size
		color: Theme.color_card_separator
	}
}
