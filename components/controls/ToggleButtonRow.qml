/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FocusScope {
	id: root

	property bool on
	property string offButtonText: CommonWords.off
	property bool useOffButtonColors: true // set to false to use standard colours for Off button

	readonly property real _buttonWidth: (width / 2) - Theme.geometry_button_border_width
	readonly property real _buttonHeight: height - (2 * Theme.geometry_button_border_width)
	property alias onButton: onButton
	property alias offButton: offButton

	signal onClicked
	signal offClicked

	implicitWidth: Theme.geometry_controlCard_minimumWidth
	implicitHeight: Theme.geometry_segmentedButtonRow_height
	focusPolicy: Qt.TabFocus

	// Background rectangle
	Rectangle {
		id: backgroundRect
		anchors.fill: parent
		color: enabled ? Theme.color_ok : Theme.color_font_disabled
		radius: Theme.geometry_button_radius
	}

	Button {
		id: offButton

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_button_border_width
			verticalCenter: parent.verticalCenter
		}
		width: root._buttonWidth
		height: root._buttonHeight
		checked: !root.on
		down: checked
		borderWidth: 0
		radius: 0 // ensure press effect does not have radius
		topLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
		bottomLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
		flat: false
		text: root.offButtonText
		focus: checked
		focusPolicy: root.focusPolicy
		KeyNavigation.right: onButton

		onClicked: root.offClicked()

		Binding {
			target: offButton
			when: root.useOffButtonColors
			property: "backgroundColor"
			value: offButton.enabled
					? (offButton.down ? Theme.color_button_off_background : Theme.color_darkOk)
					: (offButton.down ? Theme.color_button_off_background_disabled : Theme.color_background_disabled)
		}
	}

	Button {
		id: onButton

		anchors {
			right: parent.right
			rightMargin: Theme.geometry_button_border_width
			verticalCenter: parent.verticalCenter
		}
		width: root._buttonWidth
		height: root._buttonHeight
		flat: false
		checked: root.on
		down: checked
		radius: 0 // ensure press effect does not have radius
		borderWidth: 0
		topRightRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
		bottomRightRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
		text: CommonWords.on
		focus: checked
		focusPolicy: root.focusPolicy

		onClicked: root.onClicked()
	}
}
