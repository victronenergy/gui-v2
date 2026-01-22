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
	property alias onButton: onButton
	property alias offButton: offButton

	// TODO turn this type into a Control to use built-in inset properties, instead of adding these.
	property real leftInset
	property real rightInset
	property real topInset
	property real bottomInset
	property real defaultBackgroundWidth
	property real defaultBackgroundHeight

	signal onClicked
	signal offClicked

	implicitWidth: defaultBackgroundWidth + leftInset + rightInset
	implicitHeight: defaultBackgroundHeight + topInset + bottomInset
	focusPolicy: Qt.TabFocus

	// Background rectangle
	Rectangle {
		id: backgroundRect
		x: root.leftInset
		y: root.topInset
		width: root.defaultBackgroundWidth
		height: root.defaultBackgroundHeight
		color: enabled ? Theme.color_ok : Theme.color_font_disabled
		radius: Theme.geometry_button_radius
	}

	Button {
		id: offButton

		anchors.left: parent.left
		defaultBackgroundWidth: root.defaultBackgroundWidth / 2
		defaultBackgroundHeight: root.defaultBackgroundHeight - (2 * Theme.geometry_button_border_width)
		leftInset: root.leftInset + Theme.geometry_button_border_width
		topInset: root.topInset + Theme.geometry_button_border_width
		bottomInset: root.bottomInset + Theme.geometry_button_border_width
		topPadding: topInset
		bottomPadding: bottomInset
		leftPadding: leftInset

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

		anchors.right: parent.right
		defaultBackgroundWidth: root.defaultBackgroundWidth / 2
		defaultBackgroundHeight: root.defaultBackgroundHeight - (2 * Theme.geometry_button_border_width)
		rightInset: root.rightInset + Theme.geometry_button_border_width
		topInset: root.topInset + Theme.geometry_button_border_width
		bottomInset: root.bottomInset + Theme.geometry_button_border_width
		topPadding: topInset
		bottomPadding: bottomInset
		rightPadding: rightInset

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
