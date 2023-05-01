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
		Repeater {
			id: repeater

			delegate: QuantityLabel {
				id: label
				anchors.verticalCenter: parent.verticalCenter
				font.pixelSize: Theme.font.size.body2
				value: modelData.value
				unit: modelData.unit
				valueColor: Theme.color.quantityTable.quantityValue
				unitColor: Theme.color.quantityTable.quantityUnit

				Rectangle {
					id: separator

					anchors {
						right: parent.right
						rightMargin: -root.content.spacing / 2
					}
					width: Theme.geometry.listItem.separator.width
					height: parent.implicitHeight
					color: Theme.color.listItem.separator
					visible: model.index !== repeater.count - 1
				}
			}
		}
	]
}
