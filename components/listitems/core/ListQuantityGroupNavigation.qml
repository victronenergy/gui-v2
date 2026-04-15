/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

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

	// Standard layout:
	// | Primary label       | Quantity | Arrow |
	// | Caption             |  row     | icon  |
	//
	// A compact layout is used in portrait, if the primary text (or caption text) and quantity row
	// would not fit together on one line:
	// | Primary label   |            |
	// | Quantity row    | Arrow icon |
	// | Caption         |            |
	//
	// If tableMode=true, then in order to vertically align quantities across multiple table rows:
	// - In portrait, the compact layout is ALWAYS used
	// - In landscape, the compact layout is NEVER used
	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.height

		GridLayout {
			id: contentLayout

			readonly property bool compact: ((root.tableMode && Theme.screenSize === Theme.Portrait) || textWouldWrapInPortrait)
					&& !(root.tableMode && Theme.screenSize !== Theme.Portrait)
			readonly property bool textWouldWrapInPortrait: Theme.screenSize === Theme.Portrait
					&& (primaryLabel.implicitWidth + quantityRow.width > width
						|| captionLabel.implicitWidth + quantityRow.width > width)

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width - arrowIcon.width - Theme.geometry_listItem_arrow_leftMargin
			columns: compact ? 1 : 2

			Label {
				id: primaryLabel

				bottomPadding: contentLayout.compact ? Theme.geometry_listItem_content_verticalSpacing : 0
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

				Layout.rowSpan: captionLabel.visible ? 2 : 1
				Layout.alignment: contentLayout.compact ? Qt.AlignLeft : Qt.AlignRight
			}

			CaptionLabel {
				id: captionLabel

				topPadding: Theme.geometry_listItem_content_verticalSpacing
				text: root.caption
				visible: text.length > 0

				Layout.fillWidth: true
			}
		}

		ForwardIcon {
			id: arrowIcon

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			// Set opacity instead of visible, to maintain vertical alignments across multiple
			// quantity group list items even when list item is not clickable.
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
