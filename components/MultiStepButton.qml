/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseListView {
	id: root

	property int currentIndex
	property bool checked
	readonly property real _totalDelegateWidth: width - headerItem.width

	signal indexClicked(index: int)
	signal onClicked()
	signal offClicked()

	implicitWidth: parent.width
	implicitHeight: Theme.geometry_switchableoutput_control_height

	orientation: ListView.Horizontal
	focus: false
	interactive: false

	delegate: BaseListItem {

		readonly property bool lastListItem: index === root.model.length - 1

		height: root.height
		width: root._totalDelegateWidth / root.model.length

		// background border color
		Rectangle {
			anchors.fill: parent
			topRightRadius: lastListItem ? Theme.geometry_button_radius : 0
			bottomRightRadius: lastListItem ? Theme.geometry_button_radius : 0
			color: !root.enabled ? Theme.color_gray4
				: root.checked ? Theme.color_ok
				: Theme.color_button_off_background
		}

		Button {
			anchors {
				fill: parent
				topMargin: Theme.geometry_button_border_width
				bottomMargin: Theme.geometry_button_border_width
				rightMargin: lastListItem ? Theme.geometry_button_border_width : 0
			}

			radius: 0 // Override property value intitialisation from base class to ensure PressEffect renders correctly
			topLeftRadius: 0
			bottomLeftRadius: 0
			topRightRadius: lastListItem ? Theme.geometry_button_radius - Theme.geometry_button_border_width : 0
			bottomRightRadius: lastListItem ? Theme.geometry_button_radius - Theme.geometry_button_border_width : 0
			borderWidth: 0

			text: modelData.text
			font.pixelSize: Theme.font_size_body1
			flat: false
			color: root.enabled ? checked ? Theme.color_button_down_text : Theme.color_font_primary : Theme.color_font_disabled
			backgroundColor: !root.enabled ? (checked ? Theme.color_button_off_background_disabled : Theme.color_background_disabled)
					: checked ? (root.checked ? Theme.color_ok : Theme.color_button_off_background)
					: Theme.color_darkOk
			enabled: root.checked
			checked: index === root.currentIndex
			focus: true

			onClicked: root.indexClicked(index)
		}
	}

	header: BaseListItem  {
		width: Math.ceil(labelTextMetrics.tightBoundingRect.x + labelTextMetrics.tightBoundingRect.width)
			   + Theme.geometry_miniSlider_separator_width + (Theme.geometry_miniSlider_text_padding * 2)
		height: parent.height

		// background border color
		Rectangle {
			anchors.fill: parent
			topLeftRadius: Theme.geometry_slider_groove_radius
			bottomLeftRadius: Theme.geometry_slider_groove_radius
			topRightRadius: 0
			bottomRightRadius: 0
			color: !root.enabled ? Theme.color_gray4
				: root.checked ? Theme.color_ok
				: Theme.color_button_off_background
		}

		Button {
			anchors {
				fill: parent
				topMargin: Theme.geometry_button_border_width
				bottomMargin: Theme.geometry_button_border_width
				leftMargin: Theme.geometry_button_border_width
			}

			radius: 0 // Override property value intitialisation from base class to ensure PressEffect renders correctly
			topLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			bottomLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			topRightRadius: 0
			bottomRightRadius: 0

			text: root.checked ? CommonWords.on : CommonWords.off
			font.pixelSize: Theme.font_size_body1
			borderWidth: 0
			flat: false
			backgroundColor: root.enabled ? Theme.color_darkOk : Theme.color_background_disabled
			focus: true

			onClicked: root.checked ? root.offClicked() : root.onClicked()
		}

		Rectangle {
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			width: Theme.geometry_miniSlider_separator_width
			height: parent.height - (Theme.geometry_miniSlider_decorator_vertical_padding * 2)
			radius: Theme.geometry_miniSlider_separator_width / 2
			visible: currentIndex > 0
			color: root.enabled ? Theme.color_multistepbutton_separator : Theme.color_background_disabled
		}

		TextMetrics {
			id: labelTextMetrics
			font.pixelSize: Theme.font_size_body1
			text: (CommonWords.on.length > CommonWords.off.length) ? CommonWords.on : CommonWords.off
		}
	}

	Keys.onEnterPressed: focus = false
	Keys.onEscapePressed: focus = false
	Keys.onReturnPressed: focus = false
	Keys.onLeftPressed: (event) => { event.accepted = true }
	Keys.onRightPressed: (event) => { event.accepted = true }
	Keys.onUpPressed: (event) => { event.accepted = true }
	Keys.onDownPressed: (event) => { event.accepted = true }
}
