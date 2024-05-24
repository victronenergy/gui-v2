/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

RangeSlider {
	id: root

	property int decimals
	property string suffix
	property real labelWidth: Theme.geometry_settings_battery_rangeSlider_labelWidth

	implicitWidth: parent ? parent.width : 0
	implicitHeight: Theme.geometry_listItem_height
	stepSize: (to-from) / Theme.geometry_listItem_slider_stepDivsion

	leftPadding: Theme.geometry_listItem_content_horizontalMargin
		+ labelWidth
		+ Theme.geometry_listItem_slider_spacing
	rightPadding: Theme.geometry_listItem_content_horizontalMargin
		+ labelWidth
		+ Theme.geometry_listItem_slider_spacing

	Label {
		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			leftMargin: Theme.geometry_listItem_content_horizontalMargin
		}
		width: root.labelWidth
		text: Units.formatNumber(root.first.value, root.decimals) + root.suffix
		horizontalAlignment: Text.AlignRight
		font.pixelSize: Theme.font_size_body2
		color: Theme.color_font_secondary
	}

	Label {
		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry_listItem_content_horizontalMargin
		}
		width: root.labelWidth
		text: Units.formatNumber(root.second.value, root.decimals) + root.suffix
		font.pixelSize: Theme.font_size_body2
		color: Theme.color_font_secondary
	}
}
