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

	property string iconSource: "qrc:/images/icon_arrow_32.svg"
	property int iconRotation: iconSource === "qrc:/images/icon_arrow_32.svg" ? 180 : 0
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

	// Layout is like this:
	// | Primary label | Secondary label and icon (span across both rows) |
	// | Caption       |                                                  |
	contentItem: GridLayout {
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

			Layout.rowSpan: 2
			Layout.minimumWidth: Theme.geometry_listItem_textField_minimumWidth
			Layout.alignment: Qt.AlignRight

			CP.ColorImage {
				id: icon

				anchors {
					right: parent.right
					verticalCenter: parent.verticalCenter
				}
				source: root.iconSource
				rotation: root.iconRotation
				color: root.iconColor
				visible: root.interactive
			}
		}

		Label {
			text: root.caption
			color: Theme.color_font_secondary
			wrapMode: Text.Wrap
			visible: text.length > 0

			Layout.fillWidth: true
			Layout.topMargin: root.captionTopMargin
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
