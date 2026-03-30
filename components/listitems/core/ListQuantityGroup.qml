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

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.height

		Flow {
			id: contentLayout

			anchors {
				left: parent.left
				right: parent.right
				verticalCenter: parent.verticalCenter
			}

			Label {
				// If the label and quantity row do not fit side-by-side, place the row below.
				readonly property bool compactLayout: implicitWidth + root.spacing + quantityRow.width > parent.width

				bottomPadding: compactLayout ? Theme.geometry_listItem_content_verticalSpacing : 0
				width: compactLayout ? parent.width : parent.width - quantityRow.width
				text: root.text
				textFormat: root.textFormat
				font: root.font
				wrapMode: Text.Wrap
			}

			QuantityRow {
				id: quantityRow

				model: root.model
			}

			CaptionLabel {
				topPadding: Theme.geometry_listItem_content_verticalSpacing
				width: parent.width
				text: root.caption
				visible: text.length > 0
			}
		}
	}
}
