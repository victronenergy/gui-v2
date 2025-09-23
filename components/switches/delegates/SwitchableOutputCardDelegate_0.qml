/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Switch control for SwitchableOutput_Type_Momentary type.
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
			momentaryState.writeValue(1)
			event.accepted = true
		}
	}
	Keys.onReleased: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			 // If writing state=0 (off), then allow it even if a previous state=1 (on) write
			 // is in progress; the state=0 change will be queued on the backend.
			 if (!momentaryState.busy || momentaryState.expectedValue !== 0) {
				 momentaryState.writeValue(0)
			 }
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

	MomentaryButton {
		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		height: Theme.geometry_switchableoutput_control_height
		focusPolicy: Qt.NoFocus // do not focus when clicked, as this control has no edit mode

		// Show as checked, when pressing or backend indicates it is pressed
		checked: momentaryState.expectedValue === 1
			// Or when waiting for a release to be synced, else the button text flickers between
			// "On" and "Pressed" on Wasm when there is a delay between release and sync.
			|| momentaryState.busy

		// Only show the press effect when the backend has written the state succesfully.
		pressEffectRunning: momentaryState.backendValue === 1

		onPressed: momentaryState.writeValue(1)
		onReleased: momentaryState.writeValue(0)
		onCanceled: momentaryState.writeValue(0)

		SettingSync {
			id: momentaryState
			backendValue: root.switchableOutput.state
			onUpdateToBackend: (value) => { root.switchableOutput.setState(value) }
		}
	}
}
