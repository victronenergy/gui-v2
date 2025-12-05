/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Switch control for SwitchableOutput_Type_SteppedSwitch type.
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
			if (!multiStep.activeFocus) {
				multiStep.focus = true
				event.accepted = true
			}
			break
		case Qt.Key_Return:
		case Qt.Key_Enter:
		case Qt.Key_Escape:
			if (multiStep.activeFocus) {
				multiStep.focus = false
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

	MultiStepButton {
		id: multiStep

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
			top: header.bottom
		}
		objectName: root.objectName // TODO: remove
		height: Theme.geometry_switchableoutput_control_height
		checked: multiStepState.expectedValue === 1
		onOnClicked: multiStepState.writeValue(1)
		onOffClicked: multiStepState.writeValue(0)

		// Get/set the current index. Note Dimming and DimmingMax are 1-based. E.g. if Dimming=1
		// and DimmingMax=5, the options are 1-5 inclusive, and the first option is selected.
		currentIndex: root.switchableOutput.dimming - 1
		onIndexClicked: (index) => { root.switchableOutput.setDimming(index + 1) }

		Connections {
			target: root.switchableOutput
			function onDimmingChanged() {
				multiStep.currentIndex = root.switchableOutput.dimming - 1
			}
		}

		// The /DimmingMax holds the maximum value.
		VeQuickItem {
			id: multiStepMax
			uid: root.switchableOutput.uid + "/Settings/DimmingMax"
			onValueChanged: {
				if (multiStepMax.value === undefined) {
					multiStep.model = []
				} else {
					let items = []
					// limit maximum number of options
					let totalOptions = Math.min(7, multiStepMax.value)
					for (let i = 0; i < totalOptions; i++) {
						items.push({ 'text': i + 1 })   // options are 1-based
					}
					multiStep.model = items
				}
			}
		}

		SettingSync {
			id: multiStepState
			dataItem: VeQuickItem {
				uid: root.switchableOutput.uid + "/State"
			}
		}
	}
}
