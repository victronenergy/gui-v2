/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Switch control for SwitchableOutput_Type_ThreeStateSwitch type.
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
			if (!autoToggleButton.activeFocus) {
				autoToggleButton.focus = true
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

	AutoToggleButton {
		id: autoToggleButton

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		height: Theme.geometry_switchableoutput_control_height
		onChecked: toggleState.expectedValue === 1
		autoChecked: autoToggleState.expectedValue === 1
		onOnClicked: toggleState.writeValue(1)
		onOffClicked: toggleState.writeValue(0)
		onAutoClicked: autoToggleState.writeValue(autoToggleState.backendValue === 1 ? 0 : 1)

		SettingSync {
			id: autoToggleState
			backendValue: autoState.value
			onUpdateToBackend: (value) => { autoState.setValue(value) }
		}

		VeQuickItem {
			id: autoState
			uid: root.switchableOutput.uid + "/Auto"
		}

		SettingSync {
			id: toggleState
			backendValue: root.switchableOutput.state
			onUpdateToBackend: (value) => { root.switchableOutput.setState(value) }
		}
	}
}
