/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	required property SwitchableOutput switchableOutput

	enabled: root.switchableOutput.status !== VenusOS.SwitchableOutput_Status_Disabled
	focus: true
	KeyNavigationHighlight.active: activeFocus

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			bilgePumpState.writeValue(bilgePumpState.backendValue === 1 ? 0 : 1)
			event.accepted = true
		}
	}

	SwitchableOutputCardDelegateHeader {
		id: header
		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
		}
		switchableOutput: root.switchableOutput
		statusVisible: true // show status even when it is On/Off (i.e. Running/Not running)
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
		on: bilgePumpState.expectedValue === 1
		offButtonText: CommonWords.auto
		useOffButtonColors: false
		focusPolicy: Qt.NoFocus // do not focus when clicked, as this control has no edit mode

		onOnClicked: bilgePumpState.writeValue(1)
		onOffClicked: bilgePumpState.writeValue(0)

		SettingSync {
			id: bilgePumpState
			backendValue: root.switchableOutput.state
			onUpdateToBackend: (value) => { root.switchableOutput.setState(value) }
		}
	}
}
