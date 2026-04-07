/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
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
	property string iconSource: "qrc:/images/icon_chevron_right_32.svg"
	property color iconColor: Theme.color_listItem_forwardIcon

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
	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.height

		GridLayout {
			id: contentLayout

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width - arrowIcon.width - Theme.geometry_listItem_arrow_leftMargin
			columns: 2

			Label {
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
			}

			CaptionLabel {
				id: captionLabel

				topPadding: Theme.geometry_listItem_content_verticalSpacing
				text: root.caption
				visible: text.length > 0

				Layout.fillWidth: true
			}
		}

		CP.ColorImage {
			id: arrowIcon

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			source: root.iconSource
			color: root.iconColor

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
