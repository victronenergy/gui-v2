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
	property bool alignGroupColumns

	content.children: [
		ListGroupRepeater {
			id: repeater

			allowed: root.alignGroupColumns && root.allowed
			delegate: Row {
				property real columnWidth
				property alias columnImplicitWidth: label.implicitWidth

				anchors.verticalCenter: !!parent ? parent.verticalCenter : undefined
				spacing: root.content.spacing

				Label {
					id: label

					width: root.itemWidth > 0 || Math.max(implicitWidth, columnWidth)
					onImplicitWidthChanged: repeater.update()

					font.pixelSize: Theme.font_size_body2
					color: Theme.color_listItem_secondaryText
					text: modelData === undefined ? root.invalidText : modelData
					horizontalAlignment: Text.AlignRight
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
