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
	property QtObject _selectorDialog

	enabled: root.switchableOutput.status !== VenusOS.SwitchableOutput_Status_Disabled
	focus: true
	KeyNavigationHighlight.active: activeFocus && !slider.activeFocus

	// When Space is pressed: focus the slider. From there, user can press Space again to enter
	// edit mode on the slider and its On/Off button, or press Right to focus the color box.
	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			sliderContainer.focus = true
			event.accepted = true
			break
		case Qt.Key_Escape:
		case Qt.Key_Return:
		case Qt.Key_Enter:
			sliderContainer.focus = false
			colorPickerButton.focus = false
			event.accepted = true
			break
		case Qt.Key_Up:
		case Qt.Key_Down:
			if (sliderContainer.activeFocus || colorPickerButton.activeFocus) {
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

	FocusScope {
		id: sliderContainer

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: colorPickerButton.left
			rightMargin: Theme.geometry_switchableoutput_spacing
			top: header.bottom
		}
		height: slider.height
		KeyNavigationHighlight.active: activeFocus

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
		KeyNavigation.right: colorPickerButton

		SwitchableOutputDimmableSlider {
			id: slider

			width: parent.width
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
	}

	ColorButton {
		id: colorPickerButton

		anchors {
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		centerColor: Qt.hsva(currentColorDimmerData.displayColor.hsvHue,
					   currentColorDimmerData.displayColor.hsvSaturation,
					   1.0, 1.0)

		KeyNavigationHighlight.active: activeFocus
		Keys.onSpacePressed: root._selectorDialog = Global.dialogLayer.open(colorDialogComponent)
		onClicked: root._selectorDialog = Global.dialogLayer.open(colorDialogComponent)

		ColorDimmerData {
			id: currentColorDimmerData
			dataUid: root.switchableOutput.uid + "/LightControls"
			outputType: root.switchableOutput.type
		}

		Component {
			id: colorDialogComponent

			ColorWheelDialog {
				title: root.switchableOutput.formattedName
				colorDimmerData: currentColorDimmerData
				switchableOutput: root.switchableOutput
			}
		}
	}

	Component.onDestruction: {
		// Delegate may be destroyed while dialog is open, if SwitchableOutput::allowedInGroupModel
		// becomes false. If so, immediately close the dialog as the parent scope has disappeared.
		if (_selectorDialog && _selectorDialog.opened) {
			_selectorDialog.destroy()
			_selectorDialog = null
		}
	}
}
