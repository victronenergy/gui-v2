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
	property color secondaryTextColor: Theme.color_listItem_secondaryText
	property string iconSource: "qrc:/images/icon_chevron_right_24.svg"
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

	contentItem: GridLayout {
		columns: 2
		columnSpacing: root.spacing
		rowSpacing: Theme.geometry_listItem_content_verticalSpacing

		TwoLabelLayout {
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			secondaryText: root.secondaryText
			secondaryLabel.color: root.secondaryTextColor

			Layout.fillWidth: true
		}

		CP.ColorImage {
			source: root.iconSource
			color: root.iconColor
		}

		CaptionLabel {
			visible: text.length > 0
			text: root.caption

			Layout.columnSpan: 2
			Layout.fillWidth: true
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
