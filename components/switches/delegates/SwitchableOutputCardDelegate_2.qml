/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Switch control for SwitchableOutput_Type_Dimmable type.
*/
FocusScope {
	id: root

	required property SwitchableOutput switchableOutput

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
			topMargin: Theme.geometry_size_8
			left: parent.left
			leftMargin: Theme.geometry_shared_24_24_16
			right: parent.right
			rightMargin: Theme.geometry_shared_24_24_16
		}
		switchableOutput: root.switchableOutput
		quantityValue: slider.value
		quantityUnit: VenusOS.Units_Percentage
	}

	SwitchableOutputDimmableSlider {
		id: slider

		anchors {
			left: parent.left
			right: parent.right
			top: header.bottom
			topMargin: -topInset
		}
		switchableOutput: root.switchableOutput

		// Expand clickable area horizontally (to delegate edges) and vertically. Adjust paddings
		// by the same amount to fit the content within the background.
		topInset: Theme.geometry_size_14
		bottomInset: Theme.geometry_size_14
		leftInset: Theme.geometry_shared_24_24_16
		rightInset: Theme.geometry_shared_24_24_16
		topPadding: topInset
		bottomPadding: bottomInset
		rightPadding: rightInset
	}
}
