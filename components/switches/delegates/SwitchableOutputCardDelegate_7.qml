/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Switch control for SwitchableOutput_Type_BasicSlider type.
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
		secondaryTitle: quantityInfo.number + (quantityInfo.unit || root.switchableOutput.unitText)

		QuantityInfo {
			id: quantityInfo
			value: slider.value // already in the display unit
			unitType: Global.systemSettings.toPreferredUnit(root.switchableOutput.unitType)
			precision: root.switchableOutput.stepSizeDecimals
		}
	}

	SwitchableOutputSlider {
		id: slider

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		switchableOutput: root.switchableOutput
		sourceUnit: root.switchableOutput.unitType
		displayUnit: Global.systemSettings.toPreferredUnit(root.switchableOutput.unitType)
	}
}
