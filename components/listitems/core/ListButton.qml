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

	// If true, displays a text label instead of a button.
	property bool readOnly: false

	// If these are not set, the default values are used.
	property color buttonBorderColor: FastUtils.invalidColor()
	property color buttonBackgroundColor: FastUtils.invalidColor()

	signal clicked

	function click() {
		if (readOnly || !root.checkWriteAccessLevel() || !root.clickable) {
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

			anchors {
				left: parent.left
				right: button.left
				rightMargin: root.spacing
				verticalCenter: parent.verticalCenter
			}
			spacing: Theme.geometry_listItem_content_verticalSpacing

			Label {
				text: root.text
				textFormat: root.textFormat
				font: root.font
				wrapMode: Text.Wrap

				Layout.fillWidth: true
			}

			CaptionLabel {
				width: parent.width
				text: root.caption
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
			enabled: root.clickable && !root.readOnly
			flat: root.readOnly
			focusPolicy: Qt.NoFocus
			onClicked: root.click()

			// TODO ideally Button.qml makes its color/backgroundColor/borderColor customisable in a
			// way that doesn't require the normal binding to be duplicated. Once that is reworked,
			// these Binding objects can be dropped in favour of just setting something like
			// 'borderColor: root.borderColor'.
			Binding on borderColor {
				when: root.buttonBorderColor.valid
				value: root.buttonBorderColor
			}
			Binding on backgroundColor {
				when: root.buttonBackgroundColor.valid
				value: root.buttonBackgroundColor
			}
		}
	}

	Keys.onSpacePressed: click()
}
