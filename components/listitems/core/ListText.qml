/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	A list setting item with additional secondary text.
*/
ListSetting {
	id: root

	readonly property alias dataItem: dataItem
	property string secondaryText: dataItem.valid ? dataItem.value : ""
	property color secondaryTextColor: Theme.color_listItem_secondaryText

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: labelLayout.height

		ThreeLabelLayout {
			id: labelLayout

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width
			primaryText: root.text
			primaryFont: root.font
			primaryTextFormat: root.textFormat
			secondaryText: root.secondaryText
			secondaryTextColor: root.secondaryTextColor
			captionText: root.caption
			stretchCaption: true
		}
	}

	VeQuickItem {
		id: dataItem
	}
}
