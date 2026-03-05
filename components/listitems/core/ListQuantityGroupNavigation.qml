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

	function click() {
		// Just check 'interactive', and ignore 'userHasWriteAccess'. The control can be clicked
		// regardless of the write permission, since it opens a submenu instead of changing a value.
		if (interactive) {
			clicked()
		}
	}

	interactive: true
	hasSubMenu: interactive

	// The contentItem is a plain Item rather than a layout, so that the icon does not stretch the
	// height of the overall item.
	// Standard layout is:
	// | Primary label | Quantity row | Icon (spans across both rows) |
	// | Caption                      |                               |
	//
	// In portrait, if the label and quantity row do not fit side-by-side, use a compact layout:
	// | Primary label | Icon (spans all rows) |
	// | Quantity row  |                       |
	// | Caption       |                       |
	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentGrid.height

		GridLayout {
			id: contentGrid

			readonly property bool compactLayout: Theme.screenSize === Theme.Portrait
					&& root.quantityModel?.count > 1
					&& primaryLabel.implicitWidth + quantityRow.implicitWidth + icon.width > root.availableWidth

			anchors.verticalCenter: parent.verticalCenter
			columns: compactLayout ? 1 : 2
			rows: compactLayout ? 3 : 2
			columnSpacing: root.spacing
			rowSpacing: Theme.geometry_listItem_content_verticalSpacing
			width: root.availableWidth - icon.width - quantityRow.spacing

			Label {
				id: primaryLabel

				text: root.text
				textFormat: root.textFormat
				font: root.font
				wrapMode: Text.Wrap

				Layout.fillWidth: true
			}

			QuantityRow {
				id: quantityRow
				model: root.quantityModel
				tableMode: root.tableMode

				Layout.alignment: Qt.AlignRight
			}

			Label {
				text: root.caption
				font.pixelSize: Theme.font_listItem_caption_size
				color: Theme.color_font_secondary
				wrapMode: Text.Wrap
				visible: text.length > 0

				Layout.fillWidth: true
				Layout.columnSpan: contentGrid.compactLayout ? 1 : 2
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
			onClicked: root.click()
		}
	}

	Keys.onSpacePressed: click()
	Keys.onRightPressed: click()
}
