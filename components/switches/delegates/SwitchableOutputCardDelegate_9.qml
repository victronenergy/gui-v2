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
			right: parent.right
			top: header.bottom
			topMargin: -(Theme.geometry_button_touch_verticalMargin)
		}
		defaultBackgroundWidth: header.width
		defaultBackgroundHeight: Theme.geometry_switchableoutput_control_height

		onChecked: toggleState.expectedValue === 1
		autoChecked: autoToggleState.expectedValue === 1
		onOnClicked: toggleState.writeValue(1)
		onOffClicked: toggleState.writeValue(0)
		onAutoClicked: autoToggleState.writeValue(autoToggleState.dataItem.value === 1 ? 0 : 1)

		SettingSync {
			id: autoToggleState
			dataItem: autoState
		}

		VeQuickItem {
			id: autoState
			uid: root.switchableOutput.uid + "/Auto"
		}

		SettingSync {
			id: toggleState
			dataItem: VeQuickItem {
				uid: root.switchableOutput.uid + "/State"
			}
		}
	}
}
