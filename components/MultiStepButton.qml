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

	// Expand clickable area to the left of the On/Off button, and to the right of the last button.
	readonly property real horizontalPressMargin: Theme.geometry_controlCard_button_margins

	// Expand clickable area vertically for On/Off and delegate buttons.
	readonly property real verticalPressMargin: Theme.geometry_button_touch_verticalMargin

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

		width: (root._totalDelegateWidth - root.horizontalPressMargin) / root.model.length
		height: Theme.geometry_switchableoutput_control_height

		// background border color
		Rectangle {
			anchors.fill: parent
			topRightRadius: lastListItem ? Theme.geometry_button_radius : 0
			bottomRightRadius: lastListItem ? Theme.geometry_button_radius : 0
			color: !root.enabled ? Theme.color_gray4
				: root.checked ? Theme.color_ok
				: Theme.color_button_off_background
		}

		// Each button expands vertically beyond the delegate bounds, so that presses above and
		// below the button still trigger the click action. The last button also expands its
		// clickable area to the right.
		Button {
			y: -root.verticalPressMargin
			defaultBackgroundWidth: parent.width - Theme.geometry_button_border_width
			defaultBackgroundHeight: parent.height - (Theme.geometry_button_border_width * 2)
			topInset: root.verticalPressMargin + Theme.geometry_button_border_width
			bottomInset: root.verticalPressMargin + Theme.geometry_button_border_width
			rightInset: lastListItem ? root.horizontalPressMargin : 0

			// Offset the content to fit within the background.
			topPadding: topInset
			bottomPadding: bottomInset
			rightPadding: rightInset

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
			   + root.horizontalPressMargin
		height: Theme.geometry_switchableoutput_control_height

		// background border color
		Rectangle {
			id: backgroundRect
			anchors {
				fill: parent
				leftMargin: root.horizontalPressMargin
			}
			topLeftRadius: Theme.geometry_slider_groove_radius
			bottomLeftRadius: Theme.geometry_slider_groove_radius
			topRightRadius: 0
			bottomRightRadius: 0
			color: !root.enabled ? Theme.color_gray4
				: root.checked ? Theme.color_ok
				: Theme.color_button_off_background
		}

		Button {
			y: -root.verticalPressMargin
			defaultBackgroundWidth: parent.width - root.horizontalPressMargin - Theme.geometry_button_border_width
			defaultBackgroundHeight: parent.height - (Theme.geometry_button_border_width * 2)
			topInset: root.verticalPressMargin + Theme.geometry_button_border_width
			bottomInset: root.verticalPressMargin + Theme.geometry_button_border_width
			leftInset: root.horizontalPressMargin + Theme.geometry_button_border_width

			// Offset the content to fit within the background.
			topPadding: topInset
			bottomPadding: bottomInset
			leftPadding: leftInset

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
