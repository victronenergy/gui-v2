/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as CT
import Victron.VenusOS

CT.RadioButton {
	id: root

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding,
		implicitIndicatorWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding,
		implicitIndicatorHeight + topPadding + bottomPadding)

	indicator: Rectangle {
		anchors {
			right: parent.right
			verticalCenter: parent.verticalCenter
		}
		implicitWidth: Theme.geometry_radioButton_indicator_width
		implicitHeight: implicitWidth
		radius: implicitWidth/2
		border.width: Theme.geometry_radioButton_border_width
		border.color: root.enabled || root.checked
			? ((root.down || root.checked) ? Theme.color_radioButton_indicator_on : Theme.color_radioButton_indicator_off)
			: Theme.color_radioButton_indicator_disabled
		color: 'transparent'

		Rectangle {
			anchors.centerIn: parent
			implicitWidth: Theme.geometry_radioButton_indicator_dot_width
			implicitHeight: implicitWidth
			radius: implicitWidth/2
			color: root.enabled || root.checked ? Theme.color_radioButton_indicator_on : Theme.color_radioButton_indicator_disabled
			visible: root.down || root.checked
		}
	}
}
