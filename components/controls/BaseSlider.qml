/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import QtQuick.Effects as Effects

 T.Slider {
	id: root

	property color highlightColor: root.enabled ? Theme.color_ok : Theme.color_switch_groove_disabled
	property bool animationEnabled
	property int state
	property alias leftPaddingComponent: leftPaddingItemLoader.sourceComponent
	property alias rightPaddingComponent: rightPaddingItemLoader.sourceComponent

	property int nextX: root.leftPadding + root.visualPosition * (root.availableWidth - Theme.geometry_dimmingSlider_handle_width)

	signal leftPaddingClicked
	signal rightPaddingClicked

	implicitHeight: Theme.geometry_dimmingSlider_height
	leftPadding: Theme.geometry_dimmingSlider_handle_width/2

	background: Rectangle {
		width: parent.width
		height: parent.height
		radius: Theme.geometry_slider_groove_radius
		color: root.enabled ? Theme.color_darkOk : Theme.color_background_disabled

		Rectangle {
			topLeftRadius: Theme.geometry_slider_groove_radius
			bottomLeftRadius: Theme.geometry_slider_groove_radius
			topRightRadius: width > root.width - Theme.geometry_slider_groove_radius ? Theme.geometry_slider_groove_radius - (root.width - width) : 0
			bottomRightRadius: width > root.width - Theme.geometry_slider_groove_radius ? Theme.geometry_slider_groove_radius - (root.width - width) : 0

			height: root.background.height
			width: root.nextX + (Theme.geometry_dimmingSlider_handle_width)

			color: root.highlightColor
		}
		Rectangle {
			anchors.fill: parent
			color: "transparent"
			border.width: Theme.geometry_button_border_width
			border.color: root.enabled ? Theme.color_ok : Theme.color_gray4
			radius: Theme.geometry_button_radius
		}

		Loader {
			id: leftPaddingItemLoader
			anchors.left: parent.left
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			width: root.leftPadding - (Theme.geometry_dimmingSlider_handle_width / 2)
		}
		Loader {
			id: rightPaddingItemLoader
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			width: root.rightPadding
		}
	}

	handle: InternalIndicator {
			x: root.nextX + (Theme.geometry_dimmingSlider_handle_width / 2 - Theme.geometry_dimmingSlider_indicator_width)
			anchors.verticalCenter: parent.verticalCenter
	}

	component InternalIndicator : Rectangle {
		width: 4 // Theme.geometry_slider_indicator_width
		height: 28 //Theme.geometry_slider_indicator_height
		color: Theme.color_white
		radius: 2 //Theme.geometry_Slider_indicator_radius

		SliderHandleHighlight {
			anchors.centerIn: parent
			width: 28 //root.handle.height - (Theme.geometry_dimmingSlider_decorator_vertical_padding * 2)
			height: Theme.geometry_dimmingSlider_indicator_width
			visible: Global.keyNavigationEnabled && root.activeFocus
		}
	}

	MouseArea {
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: root.leftPadding - (Theme.geometry_dimmingSlider_handle_width / 2)
		onClicked: root.leftPaddingClicked()
	}
	MouseArea {
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: root.rightPadding
		onClicked: root.rightPaddingClicked()
	}
 }

