/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	property alias model: quantityRow.model

	content.children: [
		QuantityRow {
			id: quantityRow
		}
	]
}
