/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	implicitWidth: parent ? parent.width : 0
	implicitHeight: bar.height

	SeparatorBar {
		id: bar

		x: Theme.geometry_separatorBar_horizontalMargin
		width: parent.width - (2 * Theme.geometry_separatorBar_horizontalMargin)
		height: Theme.geometry_separatorBar_size
		color: Theme.color_card_separator
	}
}
