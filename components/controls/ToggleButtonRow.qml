/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	property bool on

	readonly property real _buttonWidth: (width / 2) - Theme.geometry_button_border_width
	readonly property real _buttonHeight: height - (2 * Theme.geometry_button_border_width)

	signal onClicked
	signal offClicked

	implicitWidth: Theme.geometry_controlCard_minimumWidth
	implicitHeight: Theme.geometry_segmentedButtonRow_height
	color: enabled ? Theme.color_ok : Theme.color_font_disabled
	radius: Theme.geometry_button_radius

	Button {
		id: offButton

		readonly property bool selected: !root.on

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_button_border_width
			verticalCenter: parent.verticalCenter
		}
		width: root._buttonWidth
		height: root._buttonHeight
		backgroundColor: enabled
			? (selected ? Theme.color_button_off_background : Theme.color_darkOk)
			: (selected ? Theme.color_button_off_background_disabled : Theme.color_background_disabled)
		color: enabled
			? (down || selected ? Theme.color_button_down_text : Theme.color_font_primary)
			: (selected ? Theme.color_button_on_text_disabled : Theme.color_button_off_text_disabled)
		borderWidth: 0
		topLeftRadius: root.radius - Theme.geometry_button_border_width
		bottomLeftRadius: root.radius - Theme.geometry_button_border_width
		text: CommonWords.off
		focusPolicy: root.focusPolicy

		onClicked: root.offClicked()
	}

	Button {
		id: onButton

		readonly property bool selected: root.on

		anchors {
			right: parent.right
			rightMargin: Theme.geometry_button_border_width
			verticalCenter: parent.verticalCenter
		}
		width: root._buttonWidth
		height: root._buttonHeight
		backgroundColor: enabled
			? (selected ? Theme.color_ok : Theme.color_darkOk)
			: (selected ? Theme.color_button_on_background_disabled : Theme.color_background_disabled)
		color: enabled
			? (down || selected ? Theme.color_button_down_text : Theme.color_font_primary)
			: (selected ? Theme.color_button_on_text_disabled : Theme.color_button_off_text_disabled)
		borderWidth: 0
		topRightRadius: root.radius - Theme.geometry_button_border_width
		bottomRightRadius: root.radius - Theme.geometry_button_border_width
		text: CommonWords.on
		focusPolicy: root.focusPolicy

		onClicked: root.onClicked()
	}
}
