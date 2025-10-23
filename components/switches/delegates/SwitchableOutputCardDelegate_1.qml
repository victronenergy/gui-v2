/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Switch control for SwitchableOutput_Type_Toggle type.
*/
Item {
	id: root

	required property SwitchableOutput switchableOutput

	enabled: root.switchableOutput.status !== VenusOS.SwitchableOutput_Status_Disabled
	focus: true
	KeyNavigationHighlight.active: activeFocus

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			toggleState.writeValue(toggleState.dataItem.value === 1 ? 0 : 1)
			event.accepted = true
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

	ToggleButtonRow {
		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		height: Theme.geometry_switchableoutput_control_height
		on: toggleState.expectedValue === 1
		focusPolicy: Qt.NoFocus // do not focus when clicked, as this control has no edit mode

		onOnClicked: toggleState.writeValue(1)
		onOffClicked: toggleState.writeValue(0)

		SettingSync {
			id: toggleState
			dataItem: VeQuickItem {
				uid: root.switchableOutput.uid + "/State"
			}
		}
	}
}
