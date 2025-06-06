/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListNavigation {
	id: root

	property alias quantityModel: quantityRow.model
	property alias tableMode: quantityRow.tableMode

	primaryLabel.rightPadding: quantityRow.width

	QuantityRow {
		id: quantityRow

		anchors {
			right: parent.right
			rightMargin: Theme.geometry_listItem_content_horizontalMargin + Theme.geometry_icon_size_medium
		}
		height: parent.height
	}
}
