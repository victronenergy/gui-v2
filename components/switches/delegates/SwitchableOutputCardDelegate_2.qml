/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Switch control for SwitchableOutput_Type_Dimmable type.
*/
FocusScope {
	id: root

	required property SwitchableOutput switchableOutput
	property bool editing

	function _toggleState() {
		dimmingState.writeValue(root.switchableOutput.state === 0 ? 1 : 0)
	}

	enabled: root.switchableOutput.status !== VenusOS.SwitchableOutput_Status_Disabled
	focus: true
	KeyNavigationHighlight.fill: editing ? slider : root
	KeyNavigationHighlight.active: activeFocus && !slider.activeFocus

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			if (editing) {
				_toggleState()
			} else {
				editing = true
			}
			event.accepted = true
			break
		case Qt.Key_Return:
		case Qt.Key_Enter:
		case Qt.Key_Escape:
			if (editing) {
				editing = false
				event.accepted = true
			}
			break
		case Qt.Key_Up:
		case Qt.Key_Down:
		case Qt.Key_Left:
		case Qt.Key_Right:
			// When button is 'off', the slider is disabled and does not receive
			// events, so accept them here to prevent navigation to other grid delegates.
			if (slider.activeFocus) {
				event.accepted = true
			}
			break
		}
	}

	SwitchableOutputCardDelegateHeader {
		id: header

		anchors {
			top: parent.top
			topMargin: Theme.geometry_switches_header_topMargin
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
		}
		switchableOutput: root.switchableOutput
	}

	SwitchableOutputSlider {
		id: slider

		// True when the On/Off button and the slider are both controllable.
		readonly property bool controlIsEnabled: root.enabled

		// True when the On/Off button text is "On", i.e. the slider should be controllable.
		readonly property bool sliderIsEnabled: dimmingState.expectedValue === 1 || dragging

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}

		switchableOutput: root.switchableOutput
		leftPadding: dimmingToggleButton.width
		enabled: sliderIsEnabled
		focus: root.editing
		highlightColor: controlIsEnabled
			? (sliderIsEnabled ? Theme.color_ok : Theme.color_button_off_background)
			: (sliderIsEnabled ? Theme.color_button_on_background_disabled : Theme.color_button_off_background_disabled)
		backgroundColor: controlIsEnabled ? Theme.color_darkOk : Theme.color_background_disabled
		borderColor: controlIsEnabled ? Theme.color_ok : Theme.color_font_disabled
	}

	MiniToggleButton {
		id: dimmingToggleButton

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}

		checked: dimmingState.expectedValue === 1
		onClicked: root._toggleState()

		Rectangle {
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			width: Theme.geometry_miniSlider_separator_width
			height: parent.height - (Theme.geometry_miniSlider_decorator_vertical_padding * 2)
			radius: Theme.geometry_miniSlider_separator_width / 2
			color: enabled ? Theme.color_slider_separator : Theme.color_font_disabled
		}
	}

	SettingSync {
		id: dimmingState
		backendValue: root.switchableOutput.state
		onUpdateToBackend: (value) => { root.switchableOutput.setState(value) }
	}
}
