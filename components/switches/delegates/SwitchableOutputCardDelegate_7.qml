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
			topMargin: Theme.geometry_size_8
			left: parent.left
			leftMargin: Theme.geometry_shared_24_24_16
			right: parent.right
			rightMargin: Theme.geometry_shared_24_24_16
		}
		switchableOutput: root.switchableOutput
		quantityValue: slider.value // already in the display unit
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
		topInset: Theme.geometry_size_14
		bottomInset: Theme.geometry_size_14
		leftInset: Theme.geometry_shared_24_24_16
		rightInset: Theme.geometry_shared_24_24_16
		topPadding: topInset
		bottomPadding: bottomInset
		leftPadding: leftInset
		rightPadding: rightInset
	}
}
