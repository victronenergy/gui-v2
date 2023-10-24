/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItem {
	id: root

	property alias textModel: repeater.model
	property int itemWidth

	content.children: [
		Repeater {
			id: repeater

			delegate: Label {
				id: label
				anchors.verticalCenter: parent.verticalCenter
				width: root.itemWidth
					   || (separator.visible ? implicitWidth + root.content.spacing : implicitWidth)
				font.pixelSize: Theme.font.size.body2
				color: Theme.color.listItem.secondaryText
				text: modelData === undefined ? "" : modelData
				horizontalAlignment: Text.AlignHCenter
				elide: Text.ElideRight

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
