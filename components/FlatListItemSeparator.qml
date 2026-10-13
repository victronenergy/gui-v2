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

		x: Theme.geometry_size_8
		y: -(Theme.geometry_size_4 / 2)
		width: parent.width - (2 * Theme.geometry_size_8)
		height: Theme.geometry_size_1
		color: Theme.color_card_separator
	}
}
