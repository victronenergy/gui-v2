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
	property bool forceColumnLayout

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

	// Layout is as per ListQuantityGroup (with either a wide or compact column layout depending on
	// whether the primary text and quantities can fit on the same line) but with an arrow icon
	// added on the right.
	// Note: if tableMode=true (and forceColumnLayout=false), the column layout is not used, to
	// ensure that quantities are aligned with one another across different rows.
	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.implicitHeight

		TwoLabelQuantityRowLayout {
			id: contentLayout

			anchors {
				left: parent.left
				right: arrowIcon.left
				rightMargin: Theme.geometry_listItem_arrow_leftMargin
				verticalCenter: parent.verticalCenter
			}

			primaryText: root.text
			model: root.quantityModel
			primaryLabel.textFormat: root.textFormat
			primaryLabel.font: root.font
			captionLabel.text: root.caption
			tableMode: root.tableMode
			forceColumnLayout: root.forceColumnLayout
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
