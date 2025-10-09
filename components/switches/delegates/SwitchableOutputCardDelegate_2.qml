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

	enabled: root.switchableOutput.status !== VenusOS.SwitchableOutput_Status_Disabled
	focus: true
	KeyNavigationHighlight.active: activeFocus && !slider.activeFocus

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			if (slider.activeFocus) {
				slider.toggleOutputState()
			} else {
				slider.focus = true
			}
			event.accepted = true
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

	SwitchableOutputDimmableSlider {
		id: slider

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: colorSelector.left
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		switchableOutput: root.switchableOutput
		leftPadding: dimmingToggleButton.width
		focus: root.editing
		highlightColor: enabled
			? (dimmingToggleButton.checked ? Theme.color_ok : Theme.color_button_off_background)
			: (dimmingToggleButton.checked ? Theme.color_button_on_background_disabled : Theme.color_button_off_background_disabled)
		backgroundColor: enabled ? Theme.color_darkOk : Theme.color_background_disabled
		borderColor: enabled ? Theme.color_ok : Theme.color_font_disabled
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


	Rectangle {
		id: colorSelector

		anchors {
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		implicitHeight: Theme.geometry_switchableoutput_control_height
		implicitWidth: Theme.geometry_switchableoutput_control_height
		radius: 6

		color: "green"

		MouseArea {
			anchors.fill: parent


			onClicked: Global.dialogLayer.open(colorWheelComponent, {
				r: colorSelector.color.r,
				g: colorSelector.color.g,
				b: colorSelector.color.b
			})

			Component {
				id: colorWheelComponent

				ColorWheelDialog {
					onAccepted: {
						const seconds = ClockTime.otherClockTime(year, month, day, date ? date.getHours() : 0, date ? date.getSeconds() : 0)
						if (dataItem.uid.length > 0) {
							dataItem.setValue(seconds)
						} else {
							root.date = new Date(seconds * 1000)
						}
					}
				}
			}
		}

	}

	SettingSync {
		id: dimmingState
		backendValue: root.switchableOutput.state
		onUpdateToBackend: (value) => { root.switchableOutput.setState(value) }
	}
}
