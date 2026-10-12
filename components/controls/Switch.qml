/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

T.Switch {
	id: root

	checkable: false
	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding)

	leftPadding: 0
	rightPadding: 0
	topPadding: 0
	bottomPadding: 0

	background: Rectangle {
		implicitWidth: Theme.geometry_size_44
		implicitHeight: Theme.geometry_size_20
		radius: Theme.geometry_size_24
		color: root.enabled
			   ? (root.checked ? Theme.color_switch_groove_on : Theme.color_switch_groove_off)
			   : Theme.color_switch_groove_disabled
		border.color: root.checked ? Theme.color_switch_groove_border_on
			: Theme.color_switch_groove_border_off
		border.width: Theme.geometry_size_2
	}

	indicator: Image {
		x: root.checked
			? root.background.width - width + Theme.geometry_size_2 + root.leftPadding
			: -Theme.geometry_size_2 + root.leftPadding
		y: (parent.height / 2) - (height / 2) + Theme.geometry_size_2
		width: Theme.geometry_size_28
		height: Theme.geometry_size_28
		source: "qrc:/images/switch_indicator.png"

		Behavior on x {
			id: valueChangeBehavior
			enabled: false

			XAnimator {
				duration: 200
				easing.type: Easing.InOutQuad
			}
		}
	}

	KeyNavigationHighlight.active: root.activeFocus
	KeyNavigationHighlight.leftMargin: -Theme.geometry_shared_16_16_12
	KeyNavigationHighlight.rightMargin: -Theme.geometry_shared_16_16_12
	KeyNavigationHighlight.topMargin: -Theme.geometry_listItem_content_spacing
	KeyNavigationHighlight.bottomMargin: -Theme.geometry_listItem_content_spacing

	// Don't animate the value change when setting the value on initial load
	Component.onCompleted: valueChangeBehavior.enabled = true
}
