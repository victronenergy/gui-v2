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
			topMargin: Theme.geometry_size_8
			left: parent.left
			leftMargin: Theme.geometry_shared_24_24_16
			right: parent.right
			rightMargin: Theme.geometry_shared_24_24_16
		}
		switchableOutput: root.switchableOutput
	}

	ToggleButtonRow {
		id: buttonRow

		anchors {
			left: parent.left
			right: parent.right
			top: header.bottom
			topMargin: -topInset
		}
		on: toggleState.expectedValue === 1
		focusPolicy: Qt.NoFocus // do not focus when clicked, as this control has no edit mode

		// Expand clickable area horizontally (to delegate edges) and vertically.
		defaultBackgroundWidth: header.width
		defaultBackgroundHeight: Theme.geometry_iochannel_control_height
		topInset: Theme.geometry_size_14
		bottomInset: Theme.geometry_size_14
		leftInset: Theme.geometry_shared_24_24_16
		rightInset: Theme.geometry_shared_24_24_16

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
