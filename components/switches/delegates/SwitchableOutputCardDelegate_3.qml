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

	enabled: root.switchableOutput.status !== VenusOS.SwitchableOutput_Status_Disabled
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
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		switchableOutput: root.switchableOutput
		measurementText: measurementItem.valid ? measurementItem.value.toFixed(root.switchableOutput.decimals) + Units.degreesSymbol : ""
	}
}
