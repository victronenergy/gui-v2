/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Templates as CT
import QtQuick.Controls.impl as CP
import Victron.VenusOS

CT.Switch {
	id: root

	checkable: false
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
		implicitWidth: Theme.geometry_switch_container_width
		implicitHeight: Theme.geometry_switch_container_height
		anchors.verticalCenter: parent.verticalCenter

		Rectangle {
			id: indicatorBackground

			anchors.right: parent.right
			width: Theme.geometry_switch_groove_width
			height: Theme.geometry_switch_groove_height
			radius: Theme.geometry_switch_indicator_width

			color: root.enabled
				   ? (root.checked ? Theme.color_switch_groove_on : Theme.color_switch_groove_off)
				   : Theme.color_switch_groove_disabled
			border.color: root.checked ? Theme.color_switch_groove_border_on
				: Theme.color_switch_groove_border_off
			border.width: Theme.geometry_switch_groove_border_width
		}
	}

	indicator: Image {
		x: root.checked
		   ? parent.width - width + Theme.geometry_switch_indicator_shadowOffset
		   : parent.width - indicatorBackground.width - Theme.geometry_switch_indicator_shadowOffset
		y: parent.height/2 - height/2
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

	contentItem: Item {
		anchors.verticalCenter: parent.verticalCenter

		Label {
			anchors.verticalCenter: parent.verticalCenter
			text: root.text
			color: Theme.color_font_primary
			width: parent.width - Theme.geometry_switch_groove_width
			elide: Text.ElideRight
		}
	}

	KeyNavigationHighlight {
		anchors {
			fill: parent
			leftMargin: -Theme.geometry_listItem_flat_content_horizontalMargin
			rightMargin: -Theme.geometry_listItem_flat_content_horizontalMargin
			topMargin: -Theme.geometry_listItem_content_verticalMargin
			bottomMargin: -Theme.geometry_listItem_content_verticalMargin
		}
		active: root.activeFocus
	}

	// Don't animate the value change when setting the value on initial load
	Component.onCompleted: valueChangeBehavior.enabled = true
}
