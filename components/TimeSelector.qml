/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FocusScope {
	id: root

	property alias hour: hrSpinbox.value
	property alias minute: minSpinbox.value

	property int maximumHour: 23
	property int maximumMinute: 59

	implicitWidth: hrSpinbox.width + colonLabel.width + minSpinbox.width + (2 * Theme.geometry_timeSelector_horizontalMargin)
	implicitHeight: hrSpinbox.y + hrSpinbox.height

	SpinBox {
		id: hrSpinbox
		anchors {
			right: colonLabel.left
			rightMargin: Theme.geometry_timeSelector_horizontalMargin
		}

		width: Theme.geometry_timeSelector_spinBox_width
		height: Theme.geometry_timeSelector_spinBox_height
		from: 0
		to: root.maximumHour
		//% "hr"
		secondaryText: qsTrId("timeselector_hr")
		textFromValue: (value, locale) => Utils.pad(value, 2)

		// Use BeforeItem priority to override the default key Spinbox event handling, else
		// up/down keys will modify the number even when SpinBox is not in "edit" mode.
		focus: true
		KeyNavigation.priority: KeyNavigation.BeforeItem
		KeyNavigation.up: root.KeyNavigation.up
		KeyNavigation.down: root.KeyNavigation.down
		KeyNavigation.right: minSpinbox
	}

	Label {
		id: colonLabel
		anchors {
			verticalCenter: hrSpinbox.verticalCenter
			horizontalCenter: parent.horizontalCenter
		}

		text: ":"
		color: root.enabled ? Theme.color_font_secondary : Theme.color_background_disabled
		font.pixelSize: Theme.font_size_h3
	}

	SpinBox {
		id: minSpinbox
		anchors {
			left: colonLabel.right
			leftMargin: Theme.geometry_timeSelector_horizontalMargin
		}

		width: Theme.geometry_timeSelector_spinBox_width
		height: Theme.geometry_timeSelector_spinBox_height
		from: 0
		to: root.maximumMinute
		//% "min"
		secondaryText: qsTrId("timeselector_min")
		textFromValue: (value, locale) => Utils.pad(value, 2)

		KeyNavigation.priority: KeyNavigation.BeforeItem
		KeyNavigation.up: root.KeyNavigation.up
		KeyNavigation.down: root.KeyNavigation.down
		KeyNavigation.left: hrSpinbox
	}
}
