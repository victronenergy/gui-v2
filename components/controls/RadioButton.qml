/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Templates as CT
import QtQuick.Controls.impl as CP
import Victron.VenusOS

CT.RadioButton {
	id: root

	property alias label: label

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
		implicitWidth: Theme.geometry.radioButton.indicator.width
		implicitHeight: implicitWidth
		radius: implicitWidth/2
		border.width: Theme.geometry.radioButton.border.width
		border.color: root.enabled
			? ((root.down || root.checked) ? Theme.color.radioButton.indicator.on : Theme.color.radioButton.indicator.off)
			: Theme.color.radioButton.indicator.disabled
		color: 'transparent'

		Rectangle {
			anchors.centerIn: parent
			implicitWidth: Theme.geometry.radioButton.indicator.dot.width
			implicitHeight: implicitWidth
			radius: implicitWidth/2
			color: root.enabled ? Theme.color.radioButton.indicator.on : Theme.color.radioButton.indicator.disabled
			visible: root.down || root.checked
		}
	}

	contentItem: Label {
		id: label

		font.pixelSize: Theme.font.size.body2
		text: root.text
		verticalAlignment: Text.AlignVCenter
		color: root.enabled ? Theme.color.font.primary : Theme.color.font.disabled
	}
}
