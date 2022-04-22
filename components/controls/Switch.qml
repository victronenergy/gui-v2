/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Templates as CT
import QtQuick.Controls.impl as CP
import Victron.VenusOS

CT.Switch {
	id: root

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding,
		implicitIndicatorHeight + topPadding + bottomPadding)

	leftPadding: 0
	rightPadding: 0
	topPadding: 0
	bottomPadding: 0

	background: Item {
		implicitHeight: root.indicator.implicitHeight
		implicitWidth: 2*root.indicator.implicitWidth

		Rectangle {
			anchors {
				fill: parent
				margins: Theme.geometry.switch.groove.margins
			}

			radius: root.indicator.radius
			color: root.enabled
				   ? (root.checked ? Theme.color.switch.groove.on : Theme.color.switch.groove.off)
				   : Theme.color.font.disabled
			border.color: root.checked ? Theme.color.switch.groove.border.on
				: Theme.color.switch.groove.border.off
			border.width: Theme.geometry.switch.groove.border.width
		}
	}

	indicator: Rectangle {
		implicitWidth: Theme.geometry.switch.indicator.width
		implicitHeight: implicitWidth
		radius: implicitWidth/2
		height: parent.height
		width: height
		x: root.checked ? parent.width - width : 0
		y: parent.height/2 - height/2
		color: root.enabled
			   ? Theme.color.switch.indicator.enabled
			   : Theme.color.switch.indicator.disabled

		Behavior on x {
			NumberAnimation {
				onRunningChanged: console.log("Switch animation: running:", running)
				duration: 200
				easing.type: Easing.InOutQuad
			}
		}
	}

	contentItem: Label {
		id: label
		text: root.text
		color: Theme.color.font.primary
		verticalAlignment: Text.AlignVCenter
	}
}
