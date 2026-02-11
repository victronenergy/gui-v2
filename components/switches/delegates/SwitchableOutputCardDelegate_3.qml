/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Switch control for SwitchableOutput_Type_TemperatureSetpoint type.
*/
FocusScope {
	id: root

	required property SwitchableOutput switchableOutput

	focus: true
	KeyNavigationHighlight.active: activeFocus

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			if (!slider.activeFocus) {
				slider.focus = true
				event.accepted = true
			}
			break
		case Qt.Key_Return:
		case Qt.Key_Enter:
		case Qt.Key_Escape:
			if (slider.activeFocus) {
				slider.focus = false
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
		secondaryTitle: measurementItem.valid
			? "%1%2/<font color=\"%3\">%4</font>%5"
					.arg(slider.value.toFixed(root.switchableOutput.decimals))
					.arg(Units.degreesSymbol)
					.arg(Theme.color_font_secondary)
					.arg(measurementItem.value.toFixed(root.switchableOutput.decimals))
					.arg(Global.systemSettings.temperatureUnitSuffix)
			: slider.value.toFixed(root.switchableOutput.decimals) + Global.systemSettings.temperatureUnitSuffix
	}

	VeQuickItem {
		id: measurementItem
		uid: root.switchableOutput.uid + "/Measurement"
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}

	TemperatureSlider {
		id: slider

		anchors {
			left: parent.left
			right: parent.right
			top: header.bottom
			topMargin: -topInset
		}
		switchableOutput: root.switchableOutput
		measurementText: measurementItem.valid ? measurementItem.value.toFixed(root.switchableOutput.decimals) + Units.degreesSymbol : ""

		// Expand clickable area horizontally (to delegate edges) and vertically. Adjust paddings
		// by the same amount to fit the content within the background.
		topInset: Theme.geometry_button_touch_verticalMargin
		bottomInset: Theme.geometry_button_touch_verticalMargin
		leftInset: Theme.geometry_controlCard_button_margins
		rightInset: Theme.geometry_controlCard_button_margins
		topPadding: topInset
		bottomPadding: bottomInset
		leftPadding: leftInset + leftLabelWidth
		rightPadding: rightInset + rightLabelWidth
	}
}
