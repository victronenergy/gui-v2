/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl as CP
import Victron.VenusOS

T.RangeSlider {
	id: root

	property color firstColor: "transparent"
	property color secondColor: "transparent"

	implicitWidth: Math.max(implicitBackgroundWidth, first.implicitHandleWidth, second.implicitHandleWidth) + leftInset + rightInset
	implicitHeight: Math.max(implicitBackgroundHeight, first.implicitHandleHeight, second.implicitHandleHeight) + topInset + bottomInset

	background: Rectangle {
		x: root.leftPadding
		y: root.topPadding + (root.availableHeight / 2) - (height / 2)
		implicitWidth: Theme.geometry_slider_groove_width
		implicitHeight: Theme.geometry_slider_groove_height
		width: root.availableWidth
		height: implicitHeight
		radius: Theme.geometry_slider_groove_radius
		color: enabled ? Theme.color_darkOk : Theme.color_background_disabled

		Rectangle {
			x: root.first.visualPosition * parent.width
			width: root.second.visualPosition * parent.width - x
			height: Theme.geometry_slider_groove_height
			color: enabled ? Theme.color_ok : Theme.color_switch_groove_disabled
			radius: Theme.geometry_slider_groove_radius
		}
	}

	first.handle: CP.ColorImage {
		anchors {
			left: parent.left
			leftMargin: root.leftPadding + root.first.visualPosition * (root.availableWidth - width)
			top: parent.top
			topMargin: root.topPadding + root.availableHeight / 2 - height / 2 + Theme.geometry_switch_indicator_shadowOffset
		}
		width: Theme.geometry_switch_indicator_width
		height: Theme.geometry_switch_indicator_width
		source: "qrc:/images/switch_indicator.png"
		color: root.firstColor
		focus: true

		SliderHandleHighlight {
			handle: parent
			visible: Global.keyNavigationEnabled && root.activeFocus
		}
	}

	second.handle: CP.ColorImage {
		anchors {
			left: parent.left
			leftMargin: root.leftPadding + root.second.visualPosition * (root.availableWidth - width)
			top: parent.top
			topMargin: root.topPadding + root.availableHeight / 2 - height / 2 + Theme.geometry_switch_indicator_shadowOffset
		}
		width: Theme.geometry_switch_indicator_width
		height: Theme.geometry_switch_indicator_width
		source: "qrc:/images/switch_indicator.png"
		color: root.secondColor

		SliderHandleHighlight {
			handle: parent
			visible: Global.keyNavigationEnabled && root.activeFocus
			rotation: 0
		}
	}

	Keys.onLeftPressed: first.decrease()
	Keys.onRightPressed: first.increase()
	Keys.onUpPressed: second.increase()
	Keys.onDownPressed: second.decrease()
}
