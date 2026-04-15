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

	implicitWidth: Theme.screenSize === Theme.Portrait
			? hrSpinbox.width
			: hrSpinbox.width + colonLabel.width + minSpinbox.width + (2 * Theme.geometry_modalDialog_content_spacing)
	implicitHeight: Theme.screenSize === Theme.Portrait
			? hrSpinbox.height + minSpinbox.height + Theme.geometry_modalDialog_content_spacing
			: hrSpinbox.y + hrSpinbox.height

	SpinBox {
		id: hrSpinbox

		anchors {
			right: Theme.screenSize === Theme.Portrait ? undefined : colonLabel.left
			rightMargin: Theme.geometry_modalDialog_content_spacing
			verticalCenter: Theme.screenSize === Theme.Portrait ? parent.verticalCenter : undefined
			verticalCenterOffset: -minSpinbox.height / 2
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
		font.pixelSize: Theme.font_dialog_control_largeSize
		visible: Theme.screenSize !== Theme.Portrait
	}

	SpinBox {
		id: minSpinbox

		anchors {
			left:  Theme.screenSize === Theme.Portrait ? undefined :colonLabel.right
			leftMargin: Theme.geometry_modalDialog_content_spacing
			top: Theme.screenSize === Theme.Portrait ? hrSpinbox.bottom : undefined
			topMargin: Theme.geometry_modalDialog_content_spacing
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
