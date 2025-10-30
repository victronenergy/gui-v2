/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Switch control for SwitchableOutput_Type_<RGB|RGBW|CCT> types.
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
		from: 0
		to: 1
		stepSize: 0.01
		valueDataItem: QtObject {
			readonly property real value: currentColorDimmerData.color.hsvValue
			function setValue(v) {
				currentColorDimmerData.color.hsvValue = v
				currentColorDimmerData.save()
			}
		}
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

		Rectangle {
			anchors.fill: parent
			radius: Theme.geometry_button_radius
			color: Qt.hsva(currentColorDimmerData.color.hsvHue,
						   currentColorDimmerData.color.hsvSaturation,
						   1.0, 1.0)
		}

		ColorDimmerData {
			id: currentColorDimmerData
			dataUid: root.switchableOutput.uid + "/LightControls"
		}

		VeQuickItem {
			id: validTypesItem
			uid: root.switchableOutput.uid + "/ValidTypes"
		}

		Component {
			id: colorDialogComponent

			ColorWheelDialog {
				title: root.switchableOutput.formattedName
				colorDimmerData: currentColorDimmerData
				switchableOutput: root.switchableOutput
				supportedOutputTypes: validTypesItem.valid ? validTypesItem.value : 0
			}
		}
	}
}
