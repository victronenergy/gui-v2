/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl as CP
import Victron.VenusOS

T.Button {
	id: root

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding)

	font.family: Global.fontFamily
	font.pixelSize: Theme.font_button_size
	spacing: Theme.geometry_checkBox_spacing

	FontMetrics {
		id: fontMetrics
		font: root.font
	}

	contentItem: Label {
		text: root.text
		font: root.font
		leftPadding: root.indicator.width + root.spacing
		wrapMode: Text.Wrap
	}

	indicator: Rectangle {
		y: (parent.height / 2) - (height / 2)
		implicitWidth: Theme.geometry_checkBox_size
		implicitHeight: Theme.geometry_checkBox_size
		border.width: Theme.geometry_checkBox_border_size
		border.color: root.checked ? "transparent" : Theme.color_switch_groove_border_off
		color: root.checked ? Theme.color_brand : Theme.color_background_secondary
		radius: Theme.geometry_checkBox_radius

		CP.ColorImage {
			anchors.centerIn: parent
			source: "qrc:/images/check.svg"
			visible: root.checked
			color: Theme.color_button_down_text
		}
	}

	KeyNavigationHighlight.active: root.activeFocus
	KeyNavigationHighlight.leftMargin: -Theme.geometry_button_padding
	KeyNavigationHighlight.rightMargin: -Theme.geometry_button_padding
	KeyNavigationHighlight.topMargin: -Theme.geometry_button_padding
	KeyNavigationHighlight.bottomMargin: -Theme.geometry_button_padding
}
