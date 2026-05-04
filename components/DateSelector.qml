/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

FocusScope {
	id: root

	property alias year: yearSpinbox.value
	property alias month: monthSpinbox.value
	property alias day: daySpinbox.value

	readonly property real _columnWidth: (width / 3) - (2 * Theme.geometry_modalDialog_content_spacing)

	implicitWidth: contentLayout.implicitWidth
	implicitHeight: contentLayout.implicitHeight

	Row {
		id: contentLayout

		anchors.centerIn: parent
		spacing: Theme.geometry_modalDialog_content_spacing

		SpinBox {
			id: yearSpinbox

			width: root._columnWidth
			orientation: Qt.Vertical
			spacing: Theme.geometry_spinBox_wide_spacing
			font.pixelSize: Theme.font_dialog_control_smallSize
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

			width: root._columnWidth
			orientation: Qt.Vertical
			spacing: Theme.geometry_spinBox_wide_spacing
			font.pixelSize: Theme.font_dialog_control_smallSize
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

			width: root._columnWidth
			orientation: Qt.Vertical
			spacing: Theme.geometry_spinBox_wide_spacing
			font.pixelSize: Theme.font_dialog_control_smallSize
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
