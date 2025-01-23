/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property alias year: yearSpinbox.value
	property alias month: monthSpinbox.value
	property alias day: daySpinbox.value

	property real availableWidth

	implicitWidth: yearSpinbox.width + monthSpinbox.width + daySpinbox.width + (2 * Theme.geometry_timeSelector_spacing)
	implicitHeight: yearSpinbox.height

	Row {
		height: yearSpinbox.height
		anchors.centerIn: parent

		SpinBox {
			id: yearSpinbox
			anchors.verticalCenter: parent.verticalCenter
			width: root.availableWidth > 0 ? (root.availableWidth - (Theme.geometry_modalDialog_content_horizontalMargin * 2)) / 3 : implicitWidth
			orientation: Qt.Vertical
			textInput.font.pixelSize: Theme.font_size_h2
			from: 1970
			to: 2100
			textInput.text: value
		}

		SpinBox {
			id: monthSpinbox
			anchors.verticalCenter: parent.verticalCenter
			width: root.availableWidth > 0 ? (root.availableWidth - (Theme.geometry_modalDialog_content_horizontalMargin * 2)) / 3 : implicitWidth
			orientation: Qt.Vertical
			textInput.font.pixelSize: Theme.font_size_h2
			from: 1
			to: 12
			textInput.text: Utils.pad(value, 2)
		}

		SpinBox {
			id: daySpinbox
			anchors.verticalCenter: parent.verticalCenter
			width: root.availableWidth > 0 ? (root.availableWidth - (Theme.geometry_modalDialog_content_horizontalMargin * 2)) / 3 : implicitWidth
			orientation: Qt.Vertical
			textInput.font.pixelSize: Theme.font_size_h2
			from: 1
			to: root.year,root.month, ClockTime.daysInMonth(root.month, root.year)
			textInput.text: Utils.pad(value, 2)
		}
	}
}
