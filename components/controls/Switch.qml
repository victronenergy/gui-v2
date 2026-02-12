/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

T.Switch {
	id: root

	property bool showEnabled: enabled
	property color textColor: Theme.color_font_primary

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
		x: root.leftPadding
		y: root.topPadding + (root.availableHeight / 2) - (height / 2)
		implicitWidth: Theme.geometry_switch_groove_width
		implicitHeight: Theme.geometry_switch_groove_height
		radius: Theme.geometry_switch_groove_radius
		color: root.showEnabled
			   ? (root.checked ? Theme.color_switch_groove_on : Theme.color_switch_groove_off)
			   : Theme.color_switch_groove_disabled
		border.color: root.checked ? Theme.color_switch_groove_border_on
			: Theme.color_switch_groove_border_off
		border.width: Theme.geometry_switch_groove_border_width
	}

	indicator: Image {
		x: root.checked
			? root.background.width - width + Theme.geometry_switch_indicator_shadowOffset + root.leftPadding
			: -Theme.geometry_switch_indicator_shadowOffset + root.leftPadding
		y: (parent.height / 2) - (height / 2) + Theme.geometry_switch_indicator_shadowOffset
		width: Theme.geometry_switch_indicator_width
		height: Theme.geometry_switch_indicator_width
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
	KeyNavigationHighlight.leftMargin: -Theme.geometry_listItem_flat_content_horizontalMargin
	KeyNavigationHighlight.rightMargin: -Theme.geometry_listItem_flat_content_horizontalMargin
	KeyNavigationHighlight.topMargin: -Theme.geometry_listItem_content_verticalMargin
	KeyNavigationHighlight.bottomMargin: -Theme.geometry_listItem_content_verticalMargin

	// Don't animate the value change when setting the value on initial load
	Component.onCompleted: valueChangeBehavior.enabled = true
}
