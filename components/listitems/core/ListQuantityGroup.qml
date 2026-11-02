/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListSetting {
	id: root

	property QuantityObjectModel model

	// Standard layout:
	// | Primary label       | Quantity row |
	//
	// A column layout is used if the minimum primary text length would not fit together with the
	// quantity row on one line:
	// | Primary label   |
	// | Quantity row    |
	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.implicitHeight

		ListItemQuantitiesLayout {
			id: contentLayout

			anchors {
				left: parent.left
				right: parent.right
				verticalCenter: parent.verticalCenter
			}

			text: root.text
			label.font: root.font
			label.textFormat: root.textFormat
			model: root.model
		}
	}
}
