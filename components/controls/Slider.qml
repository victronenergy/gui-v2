/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

/*
	A slider control with an optional handle.

	Note: only horizontal sliders are supported at present.
*/
T.Slider {
	id: root

	property color grooveColor: enabled ? Theme.color_darkOk : Theme.color_background_disabled
	property color highlightColor: enabled ? Theme.color_ok : Theme.color_switch_groove_disabled
	property bool showHandle: true

	implicitWidth: Math.max(implicitBackgroundWidth, implicitHandleWidth) + leftInset + rightInset
	implicitHeight: Math.max(implicitBackgroundHeight, implicitHandleHeight) + topInset + bottomInset

	background: BarGauge {
		x: root.leftPadding
		y: root.topPadding + (root.availableHeight / 2) - (height / 2)
		implicitWidth: Theme.geometry_slider_groove_width
		implicitHeight: Theme.geometry_slider_groove_height
		width: root.availableWidth
		height: implicitHeight
		radius: Theme.geometry_slider_groove_radius
		foregroundColor: root.highlightColor
		backgroundColor: root.grooveColor
		orientation: Qt.Horizontal // we have no vertical sliders at present
		animationEnabled: false // jump immediately to selected value
		value: root.visualPosition
	}

	handle: Image {
		x: visible ? root.leftPadding + root.visualPosition * (root.availableWidth - width) : 0
		y: visible ? root.topPadding + root.availableHeight / 2 - height / 2 + Theme.geometry_switch_indicator_shadowOffset : 0
		width: Theme.geometry_switch_indicator_width
		height: Theme.geometry_switch_indicator_width
		source: "qrc:/images/switch_indicator.png"
		visible: root.showHandle

		SliderHandleHighlight {
			handle: parent
			visible: Global.keyNavigationEnabled && root.activeFocus
		}
	}
}
