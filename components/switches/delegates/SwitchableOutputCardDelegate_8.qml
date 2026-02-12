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

	// TODO use insets to increase the clickable area of the +/- indicator buttons (see #2768);
	// ensure it works with the press-and-hold-for-rapid-increase/decrease feature.
	MiniSpinBox {
		id: spinBox

		function reload() {
			value = decimalConverter.decimalToInt(numericInputValueSync.dataItem.value)
		}

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		height: Theme.geometry_iochannel_control_height
		suffix: Units.defaultUnitString(Global.systemSettings.toPreferredUnit(root.switchableOutput.unitType))
				|| root.switchableOutput.unitText
		from: decimalConverter.intFrom
		to: decimalConverter.intTo
		stepSize: decimalConverter.intStepSize

		// Note: the number is displayed as the raw unscaled value (e.g. as 10000l instead of 10kl).
		// Scaling is not required, but also, showing it in a scaled format is not possible without
		// some library functions to return a non-scaled form in valueFromText().
		value: decimalConverter.decimalToInt(numericInputValueSync.dataItem.value)
		textFromValue: (value, locale) => decimalConverter.textFromValue(value)
		valueFromText: (text, locale) => {
			const v = decimalConverter.valueFromText(text)
			return isNaN(v) ? decimalConverter.decimalToInt(numericInputValueSync.dataItem.value) : v
		}
		onValueModified: {
			// Update the /Dimming value to the user-entered value.
			numericInputValueSync.writeValue(decimalConverter.intToDecimal(value))
		}

		VeQuickItem {
			id: numericInputMin
			uid: root.switchableOutput.uid + "/Settings/DimmingMin"
			sourceUnit: Units.unitToVeUnit(root.switchableOutput.unitType)
			displayUnit: Units.unitToVeUnit(Global.systemSettings.toPreferredUnit(root.switchableOutput.unitType))
		}
		VeQuickItem {
			id: numericInputMax
			uid: root.switchableOutput.uid + "/Settings/DimmingMax"
			sourceUnit: Units.unitToVeUnit(root.switchableOutput.unitType)
			displayUnit: Units.unitToVeUnit(Global.systemSettings.toPreferredUnit(root.switchableOutput.unitType))
		}
		VeQuickItem {
			id: numericInputStepSize
			uid: root.switchableOutput.uid + "/Settings/StepSize"
			sourceUnit: Units.unitToVeUnit(root.switchableOutput.unitType)
			displayUnit: Units.unitToVeUnit(Global.systemSettings.toPreferredUnit(root.switchableOutput.unitType))
		}

		MouseArea {
			anchors.fill: spinBox.contentItem
			onPressed: (event) => {
				Global.aboutToFocusTextField(spinBox.textInput, spinBox, Global.mainView.cardsLoader)
				event.accepted = false
			}
		}

		SpinBoxDecimalConverter {
			id: decimalConverter

			decimals: root.switchableOutput.decimals
			from: numericInputMin.valid ? numericInputMin.value : 0
			to: numericInputMax.valid ? numericInputMax.value : 100
			stepSize: numericInputStepSize.valid ? numericInputStepSize.value : 1

			// If the from/to is not available immediately from DimmingMin/Max, the SpinBox value is
			// clamped to the default 0-100 range, so be sure to refresh the spinBox value when the
			// DimmingMin/Max become available and the from/to are updated.
			onFromChanged: spinBox.reload()
			onToChanged: spinBox.reload()
		}

		SettingSync {
			id: numericInputValueSync
			dataItem: VeQuickItem {
				uid: root.switchableOutput.uid + "/Dimming"
				sourceUnit: Units.unitToVeUnit(root.switchableOutput.unitType)
				displayUnit: Units.unitToVeUnit(Global.systemSettings.toPreferredUnit(root.switchableOutput.unitType))
				onValueChanged: spinBox.reload()
			}
			onTimeout: spinBox.reload()
		}
	}
}
