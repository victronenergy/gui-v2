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
		implicitWidth: Theme.geometry.switch.container.width
		implicitHeight: Theme.geometry.switch.container.height
		anchors.verticalCenter: parent.verticalCenter

		Rectangle {
			anchors.centerIn: parent
			width: Theme.geometry.switch.groove.width
			height: Theme.geometry.switch.groove.height
			radius: Theme.geometry.switch.indicator.width

			color: root.enabled
				   ? (root.checked ? Theme.color.switch.groove.on : Theme.color.switch.groove.off)
				   : Theme.color.switch.groove.disabled
			border.color: root.checked ? Theme.color.switch.groove.border.on
				: Theme.color.switch.groove.border.off
			border.width: Theme.geometry.switch.groove.border.width
		}
	}

	indicator: Image {
		x: root.checked ? parent.width - width : 0
		y: parent.height/2 - height/2 + Theme.geometry.switch.indicator.shadowOffset
		width: Theme.geometry.switch.indicator.width
		height: Theme.geometry.switch.indicator.width
		source: "qrc:/images/switch_indicator.png"

		Behavior on x {
			id: valueChangeBehavior
			enabled: false

			NumberAnimation {
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

	// Don't animate the value change when setting the value on initial load
	Component.onCompleted: valueChangeBehavior.enabled = true
}
