/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	width: parent?.width ?? 0
	implicitHeight: bar.height

	SeparatorBar {
		id: bar

		x: Theme.geometry_separatorBar_horizontalMargin
		y: -(Theme.geometry_gradientList_spacing / 2)
		width: parent.width - (2 * Theme.geometry_separatorBar_horizontalMargin)
		height: Theme.geometry_separatorBar_size
		color: Theme.color_card_separator
	}
}
