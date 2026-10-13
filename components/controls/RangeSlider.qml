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
		implicitHeight: Theme.geometry_size_8
		width: root.availableWidth
		height: implicitHeight
		radius: Theme.geometry_size_8
		color: Theme.color_darkOk

		Rectangle {
			x: root.first.visualPosition * parent.width
			width: root.second.visualPosition * parent.width - x
			height: Theme.geometry_size_8
			color: Theme.color_ok
			radius: Theme.geometry_size_8
		}
	}

	first.handle: CP.ColorImage {
		anchors {
			left: parent.left
			leftMargin: root.leftPadding + root.first.visualPosition * (root.availableWidth - width)
			top: parent.top
			topMargin: root.topPadding + root.availableHeight / 2 - height / 2 + Theme.geometry_size_2
		}
		width: Theme.geometry_size_28
		height: Theme.geometry_size_28
		source: "qrc:/images/switch_indicator.png"
		color: root.firstColor

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
			topMargin: root.topPadding + root.availableHeight / 2 - height / 2 + Theme.geometry_size_2
		}
		width: Theme.geometry_size_28
		height: Theme.geometry_size_28
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
