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

	enabled: root.switchableOutput.status !== VenusOS.SwitchableOutput_Status_Disabled
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
			topMargin: Theme.geometry_switches_header_topMargin
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
		}
		switchableOutput: root.switchableOutput
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
		topInset: Theme.geometry_button_touch_verticalMargin
		bottomInset: Theme.geometry_button_touch_verticalMargin
		leftInset: Theme.geometry_controlCard_button_margins
		rightInset: Theme.geometry_controlCard_button_margins
		topPadding: topInset
		bottomPadding: bottomInset
		rightPadding: rightInset
	}
}
