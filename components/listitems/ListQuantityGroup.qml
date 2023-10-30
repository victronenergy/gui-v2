/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	property alias textModel: repeater.model

	content.spacing: Theme.geometry.listItem.content.spacing * 2
	content.children: [
		QuantityRepeater {
			id: repeater
		}

	]
}
