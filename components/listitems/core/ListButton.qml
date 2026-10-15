/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	A list setting item with a button on the right.

	When interactive=false, the primary text and button are dimmed.

	When readOnly=true, the button text is shown without a background, i.e. as if it was plain text,
	without the look of a button.
*/
ListSetting {
	id: root

	property string secondaryText
	property int secondaryFontSize: Theme.font_listItem_secondary_size

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

	// If true, displays a text label instead of a button.
	property bool readOnly: false

	interactive: true

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.isMultiLine ? contentLayout.implicitHeight : 0

		TwoLabelItemLayout {
			id: contentLayout

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			primaryLabel.color: root.interactive ? Theme.color_font_primary : Theme.color_font_disabled
			captionText: root.caption

			secondaryComponent: ListItemButton {
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
	}

	background: ListSettingAccessCheckBackground {
		listItem: root
		enabled: !root.clickable && !root.readOnly && !root.userHasWriteAccess
	}

	Keys.onSpacePressed: click()
}
