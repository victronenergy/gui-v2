/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

/*
	A list setting item with an arrow icon to go to a subpage, and optional secondary text.

	If you need a different contentItem, extend ListNavigationBase instead, so that this
	contentItem is not constructed and then discarded.
*/
ListNavigationBase {
	id: root

	property string iconSource: "qrc:/images/icon_chevron_right_32.svg"
	property color iconColor: Theme.color_listItem_forwardIcon

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: labelLayout.implicitHeight

		ThreeLabelLayout {
			id: labelLayout

			anchors {
				left: parent.left
				right: parent.right
				rightMargin: arrowIcon.visible ? arrowIcon.width + root.spacing : 0
				verticalCenter: parent.verticalCenter
			}
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			secondaryText: root.secondaryText
			secondaryLabel.color: root.secondaryTextColor
			captionText: root.caption
			stretchSecondaryText: true
		}

		CP.ColorImage {
			id: arrowIcon

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			source: root.iconSource
			color: root.iconColor
			visible: root.interactive
		}
	}
}
