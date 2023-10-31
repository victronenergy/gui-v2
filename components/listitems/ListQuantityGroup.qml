/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	property alias textModel: repeater.model
	property alias minimumDelegateWidth: repeater.minimumDelegateWidth

	content.spacing: Theme.geometry.listItem.content.spacing * 2
	content.children: [
		QuantityRepeater {
			id: repeater
		}
	]
}
