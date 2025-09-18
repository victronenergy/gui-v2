/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Switch control for SwitchableOutput_Type_NumericInput type.
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
			// Enter edit mode.
			if (!spinBox.activeFocus) {
				spinBox.focus = true
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

	MiniSpinBox {
		id: spinBox

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		height: Theme.geometry_switchableoutput_control_height
		editable: !Global.isGxDevice // no room for VKB in the switch pane
		suffix: numericInputUnit.value ?? ""
		from: decimalConverter.intFrom
		to: decimalConverter.intTo
		stepSize: decimalConverter.intStepSize
		value: decimalConverter.decimalToInt(numericInputValueSync.backendValue)
		textFromValue: (value, locale) => decimalConverter.textFromValue(value)
		valueFromText: (text, locale) => {
			const v = decimalConverter.valueFromText(text)
			return isNaN(v) ? decimalConverter.decimalToInt(numericInputValueSync.backendValue) : v
		}
		onValueModified: {
			// Update the /Dimming value to the user-entered value.
			numericInputValueSync.writeValue(decimalConverter.intToDecimal(value))
		}

		VeQuickItem {
			id: numericInputMin
			uid: root.switchableOutput.uid + "/Settings/DimmingMin"
		}
		VeQuickItem {
			id: numericInputMax
			uid: root.switchableOutput.uid + "/Settings/DimmingMax"
		}
		VeQuickItem {
			id: numericInputStepSize
			readonly property int decimalCount: valid ? value.toString().split(".")[1]?.length ?? 0 : 0
			uid: root.switchableOutput.uid + "/Settings/StepSize"
		}
		VeQuickItem {
			id: numericInputUnit
			uid: root.switchableOutput.uid + "/Settings/Unit"
		}

		SpinBoxDecimalConverter {
			id: decimalConverter

			decimals: numericInputStepSize.decimalCount
			from: numericInputMin.valid ? numericInputMin.value : 0
			to: numericInputMax.valid ? numericInputMax.value : 100
			stepSize: numericInputStepSize.valid ? numericInputStepSize.value : 1
		}

		SettingSync {
			id: numericInputValueSync
			backendValue: root.switchableOutput.dimming
			onUpdateToBackend: (value) => { root.switchableOutput.setDimming(value) }
			onTimeout: spinBox.value = decimalConverter.decimalToInt(backendValue)
		}
	}
}
