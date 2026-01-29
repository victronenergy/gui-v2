/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS
import QtQuick.Controls.impl as CP

/*
	A list item with main text, a row of QuantityLabels, and an arrow icon to go to a subpage.
*/
ListSetting {
	id: root

	property string text
	property QuantityObjectModel quantityModel
	property bool tableMode

	signal clicked

	interactive: true
	hasSubMenu: interactive

	// The contentItem is a plain Item rather than a layout, so that the icon does not stretch the
	// height of the overall item. The layout is like this:
	// | Primary label | Quantity row | Icon (spans across both rows) |
	// | Caption                      |                               |
	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentGrid.height

		GridLayout {
			id: contentGrid

			columns: 2
			columnSpacing: root.spacing
			rowSpacing: Theme.geometry_listItem_content_verticalSpacing
			width: parent.width - icon.width

			Label {
				text: root.text
				textFormat: root.textFormat
				font: root.font
				wrapMode: Text.Wrap

				Layout.fillWidth: true
			}

			QuantityRow {
				model: root.quantityModel
				tableMode: root.tableMode

				Layout.alignment: Qt.AlignRight
			}

			Label {
				text: root.caption
				color: Theme.color_font_secondary
				wrapMode: Text.Wrap
				visible: text.length > 0

				Layout.columnSpan: 2
				Layout.maximumWidth: parent.width
			}
		}

		CP.ColorImage {
			id: icon

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			source: "qrc:/images/icon_arrow_32.svg"
			rotation: 180
			color: Theme.color_listItem_forwardIcon

			// Set opacity instead of visible, to maintain the quantity label vertical alignments
			// even when list item is not clickable.
			opacity: root.interactive ? 1 : 0
		}
	}

	background: ListSettingBackground {
		color: root.flat ? "transparent" : Theme.color_listItem_background
		indicatorColor: root.backgroundIndicatorColor

		ListPressArea {
			anchors.fill: parent
			enabled: root.interactive
			onClicked: root.clicked()
		}
	}

	Keys.onSpacePressed: clicked()
	Keys.onRightPressed: clicked()
}
