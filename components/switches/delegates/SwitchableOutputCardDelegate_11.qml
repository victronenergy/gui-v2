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
			right: colorPickerButton.left
			rightMargin: Theme.geometry_switchableoutput_spacing
			top: header.bottom
		}
		switchableOutput: root.switchableOutput
	}

	PressArea {
		id: colorPickerButton

		anchors {
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		implicitWidth: Theme.geometry_switchableoutput_control_height
		implicitHeight: Theme.geometry_switchableoutput_control_height

		onClicked: Global.dialogLayer.open(colorDialogComponent)

		Timer {
			running: true
			interval: 800
			onTriggered: Global.dialogLayer.open(colorDialogComponent)
		}

		Rectangle {
			anchors.fill: parent
			radius: Theme.geometry_button_radius
			color: Theme.color_ok // TODO set colour from backend
		}

		Component {
			id: colorDialogComponent

			ColorWheelDialog {
				id: colorDialog

				title: root.switchableOutput.formattedName

				// TODO fill from backend
				rgbPresetModel: [
					Qt.rgba(1, 1, 0, 1),
					Qt.rgba(0, 1, 1, 1),
					Qt.rgba(1, 0, 1, 1),
					Qt.rgba(1, 0, 0, 1),
					Qt.rgba(0, 1, 0, 1),
					undefined,
					undefined,
					undefined,
					undefined,
				]

				// TODO fill from backend
				temperaturePresetModel: [
					Qt.rgba(1, 0.6, 0.2, 1),
					Qt.rgba(1, 0.8, 0.6, 1),
					Qt.rgba(0.6, 0.8, 0.9, 1),
					Qt.rgba(0.7, 0.8, 1, 1),
					undefined,
					undefined,
					undefined,
					undefined,
					undefined,
				]

				onAccepted: {
					console.log("TODO: save RGB values:", JSON.stringify(rgbPresetModel))
					console.log("TODO: save Temperature values:", JSON.stringify(temperaturePresetModel))
				}
			}
		}
	}
}
