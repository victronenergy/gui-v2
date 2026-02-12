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

	readonly property real _totalDelegateWidth: width - (headerItem?.width ?? 0) - Theme.geometry_button_border_width

	signal indexClicked(index: int)
	signal onClicked()
	signal offClicked()

	implicitWidth: parent.width
	implicitHeight: Theme.geometry_switchableoutput_control_height

	orientation: ListView.Horizontal
	focus: false
	interactive: false

	// Background rectangle
	Rectangle {
		anchors.horizontalCenter: parent.horizontalCenter
		width: parent.width - (2 * root.horizontalPressMargin)
		height: Theme.geometry_switchableoutput_control_height
		color: enabled ? Theme.color_ok : Theme.color_font_disabled
		radius: Theme.geometry_button_radius
		z: -1
	}

	// Each button expands vertically beyond the delegate bounds, so that presses above and
	// below the button still trigger the click action. The last button also expands its
	// clickable area to the right.
	delegate: FocusScope {
		readonly property bool lastListItem: index === root.model.length - 1

		implicitWidth: numberButton.width
		implicitHeight: numberButton.height

		// Allow Utils.acceptsKeyNavigation() to accept moving focus to this item.
		focusPolicy: root.checked ? Qt.TabFocus : Qt.NoFocus

		Button {
			id: numberButton

			y: -root.verticalPressMargin
			defaultBackgroundWidth: (root._totalDelegateWidth - root.horizontalPressMargin) / root.model.length
			defaultBackgroundHeight: Theme.geometry_switchableoutput_control_height - (2 * Theme.geometry_button_border_width)
			topInset: root.verticalPressMargin + Theme.geometry_button_border_width
			bottomInset: root.verticalPressMargin + Theme.geometry_button_border_width
			rightInset: lastListItem ? root.horizontalPressMargin : 0

			// Offset the content to fit within the background.
			topPadding: topInset
			bottomPadding: bottomInset
			rightPadding: rightInset

			topLeftRadius: 0
			topRightRadius: lastListItem ? Theme.geometry_button_radius - Theme.geometry_button_border_width : 0
			bottomLeftRadius: 0
			bottomRightRadius: lastListItem ? Theme.geometry_button_radius - Theme.geometry_button_border_width : 0
			borderWidth: 0
			flat: false
			text: modelData.text
			font.pixelSize: Theme.font_size_body1
			color: root.enabled
					? (checked ? Theme.color_button_down_text : Theme.color_font_primary)
					: Theme.color_font_disabled
			backgroundColor: !root.enabled ? (checked ? Theme.color_button_off_background_disabled : Theme.color_background_disabled)
					: checked ? (root.checked ? Theme.color_ok : Theme.color_button_off_background)
					: Theme.color_darkOk
			enabled: root.checked
			checked: index === root.currentIndex
			focus: true

			onClicked: root.indexClicked(index)
		}
	}

	header: FocusScope {
		implicitWidth: stateToggleButton.width
		implicitHeight: stateToggleButton.height

		// Allow Utils.acceptsKeyNavigation() to accept moving focus to this item.
		focusPolicy: Qt.TabFocus

		MiniToggleButton {
			id: stateToggleButton

			y: -root.verticalPressMargin
			defaultBackgroundHeight: Theme.geometry_switchableoutput_control_height - (2 * Theme.geometry_button_border_width)
			topInset: root.verticalPressMargin + Theme.geometry_button_border_width
			bottomInset: root.verticalPressMargin + Theme.geometry_button_border_width
			leftInset: root.horizontalPressMargin + Theme.geometry_button_border_width

			// Offset the content to fit within the background.
			topPadding: topInset
			bottomPadding: bottomInset
			leftPadding: leftInset

			topLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			topRightRadius: 0
			bottomLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			bottomRightRadius: 0
			borderWidth: 0
			flat: false
			color: enabled ? Theme.color_font_primary : Theme.color_font_disabled
			backgroundColor: root.enabled ? Theme.color_darkOk : Theme.color_background_disabled
			checked: root.checked
			focus: true
			separatorColor: enabled ? Theme.color_multistepbutton_separator : Theme.color_font_disabled
			separatorVisible: root.currentIndex !== 0

			onClicked: root.checked ? root.offClicked() : root.onClicked()
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
