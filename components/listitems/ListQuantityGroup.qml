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
	property bool alignGroupColumns: true

	content.spacing: 0
	content.children: [
		QuantityRepeater {
			id: repeater
			allowed: root.allowed && root.alignGroupColumns
		}
	]
}
