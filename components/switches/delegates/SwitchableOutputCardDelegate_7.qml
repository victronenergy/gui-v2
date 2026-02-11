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
			precision: root.switchableOutput.decimals
		}
	}

	SwitchableOutputSlider {
		id: slider

		anchors {
			left: parent.left
			right: parent.right
			top: header.bottom
			topMargin: -topInset
		}
		switchableOutput: root.switchableOutput
		sourceUnit: root.switchableOutput.unitType
		displayUnit: Global.systemSettings.toPreferredUnit(root.switchableOutput.unitType)

		// Expand clickable area horizontally (to delegate edges) and vertically. Adjust paddings
		// by the same amount to fit the content within the background.
		topInset: Theme.geometry_button_touch_verticalMargin
		bottomInset: Theme.geometry_button_touch_verticalMargin
		leftInset: Theme.geometry_controlCard_button_margins
		rightInset: Theme.geometry_controlCard_button_margins
		topPadding: topInset
		bottomPadding: bottomInset
		leftPadding: leftInset
		rightPadding: rightInset
	}
}
