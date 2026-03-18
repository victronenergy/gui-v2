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
	// | Primary label | Quantity row | Arrow |
	// | Caption                      | icon |
	//
	// A compact layout is used if the text and quantity row would not fit together on one line, put
	// the quantity row on the second line:
	// | Primary label   |            |
	// | Quantity row    | Arrow icon |
	// | Caption         |            |
	//
	// If tableMode=true, then in order to vertically align quantities across multiple table rows:
	// - In landscape, the compact layout is NEVER used
	// - In portrait, the compact layout is ALWAYS used
	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.height + Theme.geometry_listItem_content_verticalSpacing + captionLabel.height

		Flow {
			id: contentLayout

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width - arrowIcon.width - Theme.geometry_listItem_arrow_leftMargin

			Label {
				readonly property bool compactLayout: !(root.tableMode && Theme.screenSize !== Theme.Portrait)
					&& ((root.tableMode && Theme.screenSize === Theme.Portrait)
						|| (implicitWidth + quantityRow.width > contentLayout.width))

				bottomPadding: compactLayout ? Theme.geometry_listItem_content_verticalSpacing : 0
				width: compactLayout ? parent.width : parent.width - quantityRow.width
				text: root.text
				textFormat: root.textFormat
				font: root.font
				wrapMode: Text.Wrap
			}

			QuantityRow {
				id: quantityRow

				model: root.quantityModel
				tableMode: root.tableMode
			}

			CaptionLabel {
				id: captionLabel

				topPadding: Theme.geometry_listItem_content_verticalSpacing
				width: contentLayout.width
				text: root.caption
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
