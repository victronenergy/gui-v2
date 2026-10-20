/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	The content of a ListButton, with a caption under it.

	ListButton centers its content in the list item, so a caption cannot be added below that
	content without covering it. This draws the same content, and the caption under it, as
	ListSwitch does. With an empty caption, the height matches ListButton's own content item.
*/
Item {
	id: root

	required property ListButton listItem
	property string caption

	implicitWidth: Theme.geometry_listItem_width
	implicitHeight: contentLayout.isMultiLine || root.caption.length > 0
			? contentLayout.implicitHeight + captionLabel.height
			: 0

	ListItemLoaderLayout {
		id: contentLayout

		anchors.verticalCenter: parent.verticalCenter
		anchors.verticalCenterOffset: -captionLabel.height / 2
		width: parent.width
		text: root.listItem.text
		label.font: root.listItem.font
		label.textFormat: root.listItem.textFormat
		label.color: root.listItem.interactive ? Theme.color_font_primary : Theme.color_font_disabled
		loader.sourceComponent: ListItemButton {
			text: root.listItem.secondaryText
			font.pixelSize: root.listItem.secondaryFontSize
			down: root.listItem.clickable && (pressed || checked)
			enabled: root.listItem.clickable && !root.listItem.readOnly
			flat: root.listItem.readOnly
			focusPolicy: Qt.NoFocus
			onClicked: root.listItem.click()

			// Same as ListButton: a custom color replaces the button's own color binding.
			Binding on borderColor {
				when: root.listItem.buttonBorderColor.valid
				value: root.listItem.buttonBorderColor
			}
			Binding on backgroundColor {
				when: root.listItem.buttonBackgroundColor.valid
				value: root.listItem.buttonBackgroundColor
			}
		}
	}

	CaptionLabel {
		id: captionLabel

		anchors.top: contentLayout.bottom
		topPadding: Theme.geometry_listItem_content_verticalSpacing
		width: parent.width
		text: root.caption
		visible: text.length > 0
	}
}
