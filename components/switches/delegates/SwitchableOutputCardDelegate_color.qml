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

	KeyNavigationHighlight.active: activeFocus && !sliderScope.activeFocus && !slider.activeFocus && !colorButton.activeFocus

	// When Space is pressed: focus the slider. From there, user can press Space again to enter
	// edit mode on the slider and its On/Off button, or press Right/Tab to focus the color box.
	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			colorButton.focus = true
			sliderScope.focus = true
			event.accepted = true
			break
		case Qt.Key_Escape:
		case Qt.Key_Return:
		case Qt.Key_Enter:
			sliderScope.focus = false
			colorButton.focus = false
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

	FocusScope {
		id: sliderScope

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: colorButton.left
			rightMargin: Theme.geometry_switchableoutput_spacing
			top: header.bottom
		}

		height: slider.height

		focus: false

		KeyNavigationHighlight.active: activeFocus
		KeyNavigation.right: colorButton
		Keys.onPressed: (event) => {
			switch (event.key) {
			case Qt.Key_Space:
				slider.focus = true
				event.accepted = true
				break
			case Qt.Key_Escape:
			case Qt.Key_Return:
			case Qt.Key_Enter:
				slider.focus = false
				sliderScope.focus = false
				event.accepted = true
				break
			case Qt.Key_Tab:
				colorButton.focus = true
				sliderScope.focus = false
				event.accepted = true
				break
			case Qt.Key_Up:
			case Qt.Key_Down:
				slider.toggleOutputState()
				event.accepted = true
				break
			case Qt.Key_Left:
				// Unset focus from everything, and bubble the event up to the parent focus scope.
				// This ensures that when we navigate back to this delegate, the entire
				// delegate has focus, rather than this sliderScope.
				slider.focus = false
				sliderScope.focus = false
				colorButton.focus = false
				event.accepted = false
			}
		}

		SwitchableOutputDimmableSlider {
			id: slider

			width: parent.width
			focus: false
			activeFocusOnTab: false

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

			KeyNavigationHighlight.active: activeFocus
			KeyNavigation.right: colorButton
			Keys.onPressed: (event) => {
				switch (event.key) {
				case Qt.Key_Space:
					slider.toggleOutputState()
					event.accepted = true
					break
				case Qt.Key_Return:
				case Qt.Key_Enter:
				case Qt.Key_Escape:
					slider.focus = false
					event.accepted = true
					break
				}
			}
		}
	}

	ColorButton {
		id: colorButton

		anchors {
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}

		focus: false

		centerColor: Qt.hsva(currentColorDimmerData.displayColor.hsvHue,
					   currentColorDimmerData.displayColor.hsvSaturation,
					   1.0, 1.0)

		KeyNavigationHighlight.active: activeFocus
		KeyNavigation.left: sliderScope
		Keys.onPressed: (event) => {
			switch (event.key) {
			case Qt.Key_Up:
			case Qt.Key_Down:
				// just eat the event.  up/down does nothing when the color box is focused.
				event.accepted = true
				break
			case Qt.Key_Backtab:
				colorButton.focus = false
				sliderScope.focus = true
				event.accepted = true
				break
			case Qt.Key_Right:
			case Qt.Key_Tab:
				// Unset focus from everything, and bubble the event up to the parent focus scope.
				// This tells Qt that we're exhausted this focus scope, and tab should navigate
				// to the next delegate entirely.
				slider.focus = false
				sliderScope.focus = false
				colorButton.focus = false
				event.accepted = false
				break
			}
		}
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
