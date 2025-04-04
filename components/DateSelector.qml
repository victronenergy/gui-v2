/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FocusScope {
	id: root

	property alias year: yearSpinbox.value
	property alias month: monthSpinbox.value
	property alias day: daySpinbox.value

	property real availableWidth

	implicitWidth: yearSpinbox.width + monthSpinbox.width + daySpinbox.width + (2 * Theme.geometry_timeSelector_horizontalMargin)
	implicitHeight: yearSpinbox.height

	Row {
		height: yearSpinbox.height
		anchors.centerIn: parent

		SpinBox {
			id: yearSpinbox
			anchors.verticalCenter: parent.verticalCenter
			width: root.availableWidth > 0 ? (root.availableWidth - (Theme.geometry_modalDialog_content_horizontalMargin * 2)) / 3 : implicitWidth
			orientation: Qt.Vertical
			spacing: Theme.geometry_spinBox_wide_spacing
			textInput.font.pixelSize: Theme.font_size_h2
			from: 1970
			to: 2100

			// Use BeforeItem priority to override the default key Spinbox event handling, else
			// up/down keys will modify the number even when SpinBox is not in "edit" mode.
			focus: true
			KeyNavigation.priority: KeyNavigation.BeforeItem
			KeyNavigation.up: root.KeyNavigation.up
			KeyNavigation.down: root.KeyNavigation.down
			KeyNavigation.right: monthSpinbox
		}

		SpinBox {
			id: monthSpinbox
			anchors.verticalCenter: parent.verticalCenter
			width: root.availableWidth > 0 ? (root.availableWidth - (Theme.geometry_modalDialog_content_horizontalMargin * 2)) / 3 : implicitWidth
			orientation: Qt.Vertical
			spacing: Theme.geometry_spinBox_wide_spacing
			textInput.font.pixelSize: Theme.font_size_h2
			from: 1
			to: 12
			textFromValue: (value, locale) => Utils.pad(value, 2)

			KeyNavigation.priority: KeyNavigation.BeforeItem
			KeyNavigation.up: root.KeyNavigation.up
			KeyNavigation.down: root.KeyNavigation.down
			KeyNavigation.right: daySpinbox
		}

		SpinBox {
			id: daySpinbox
			anchors.verticalCenter: parent.verticalCenter
			width: root.availableWidth > 0 ? (root.availableWidth - (Theme.geometry_modalDialog_content_horizontalMargin * 2)) / 3 : implicitWidth
			orientation: Qt.Vertical
			spacing: Theme.geometry_spinBox_wide_spacing
			textInput.font.pixelSize: Theme.font_size_h2
			from: 1
			to: root.year,root.month, ClockTime.daysInMonth(root.month, root.year)
			textFromValue: (value, locale) => Utils.pad(value, 2)

			KeyNavigation.priority: KeyNavigation.BeforeItem
			KeyNavigation.up: root.KeyNavigation.up
			KeyNavigation.down: root.KeyNavigation.down
			KeyNavigation.left: monthSpinbox
		}
	}
}
