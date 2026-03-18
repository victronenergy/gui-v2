/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

/*
	A list setting item with an arrow icon to go to a subpage, and optional secondary text.
*/
ListSetting {
	id: root

	property string secondaryText
	property string secondaryTextColor: Theme.color_listItem_secondaryText
	property real captionTopMargin: Theme.geometry_listItem_content_verticalSpacing

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

	// Standard layout is:
	// | Primary label | Secondary label and icon (span across both rows) |
	// | Caption       |                                                  |
	//
	// In Portrait layout, if the caption and secondary text are both set, stretch the caption to
	// the right edge, else it looks odd if the caption text is bunched up (e.g. the 'Demo mode'
	// setting in General setting).
	// | Primary label | Secondary label and icon |
	// | Caption                                  |
	contentItem: GridLayout {
		id: gridLayout

		readonly property bool stretchCaption: Theme.screenSize === Theme.Portrait
				&& root.caption.length > 0
				&& root.secondaryText.length > 0

		columnSpacing: root.spacing
		rowSpacing: 0
		columns: 2

		Label {
			text: root.text
			textFormat: root.textFormat
			font: root.font
			wrapMode: Text.Wrap

			Layout.fillWidth: true
		}

		SecondaryListLabel {
			rightPadding: icon.visible ? icon.width + root.spacing : 0
			text: root.secondaryText
			color: root.secondaryTextColor
			wrapMode: Text.Wrap

			Layout.rowSpan: gridLayout.stretchCaption ? 1 : 2
			Layout.alignment: Qt.AlignRight
			Layout.maximumWidth: root.availableWidth * 2/3

			CP.ColorImage {
				id: icon

				anchors {
					right: parent.right
					verticalCenter: parent.verticalCenter
				}
				source: "qrc:/images/icon_arrow_32.svg"
				rotation: 180
				color: Theme.color_listItem_forwardIcon
				visible: root.interactive
			}
		}

		Label {
			text: root.caption
			font.pixelSize: Theme.font_listItem_caption_size
			color: Theme.color_font_secondary
			wrapMode: Text.Wrap
			visible: text.length > 0

			Layout.fillWidth: true
			Layout.topMargin: root.captionTopMargin
			Layout.columnSpan: gridLayout.stretchCaption ? 2 : 1
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
