/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItem {
	id: root

	property alias textModel: repeater.model
	property int itemWidth
	property string invalidText: "--"

	content.children: [
		Repeater {
			id: repeater

			delegate: Row {
				anchors.verticalCenter: !!parent ? parent.verticalCenter : undefined
				spacing: root.content.spacing
				Label {
					width: root.itemWidth || implicitWidth
					font.pixelSize: Theme.font_size_body2
					color: Theme.color_listItem_secondaryText
					text: modelData === undefined ? root.invalidText : modelData
					horizontalAlignment: Text.AlignHCenter
					elide: Text.ElideRight
				}

				Rectangle {
					width: Theme.geometry_listItem_separator_width
					height: parent.implicitHeight
					color: Theme.color_listItem_separator
					visible: model.index !== repeater.count - 1
				}
			}
		}
	]
}
