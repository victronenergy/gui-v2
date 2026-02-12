/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	A list setting item with a button on the right.
*/
ListSetting {
	id: root

	property string secondaryText
	property int secondaryFontSize: Theme.font_size_body2

	signal clicked

	function click() {
		if (!root.checkWriteAccessLevel() || !root.clickable) {
			return
		}
		root.clicked()
	}

	interactive: true

	// Use an Item instead of a layout, so that the button doesn't stretch the height of the
	// content. Layout is like this:
	// | Primary label | Button (spans across both rows) |
	// | Caption       |                                 |
	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: labelsColumn.height

		ColumnLayout {
			id: labelsColumn

			width: parent.width - button.width - root.spacing
			spacing: Theme.geometry_listItem_content_verticalSpacing

			Label {
				text: root.text
				textFormat: root.textFormat
				font: root.font
				wrapMode: Text.Wrap

				Layout.fillWidth: true
			}

			Label {
				text: root.caption
				color: Theme.color_font_secondary
				wrapMode: Text.Wrap
				visible: text.length > 0

				Layout.fillWidth: true
			}
		}

		ListItemButton {
			id: button

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			text: root.secondaryText
			font.pixelSize: root.secondaryFontSize
			down: root.clickable && (pressed || checked)
			enabled: root.clickable
			focusPolicy: Qt.NoFocus

			onClicked: root.click()
		}
	}

	Keys.onSpacePressed: click()
}
