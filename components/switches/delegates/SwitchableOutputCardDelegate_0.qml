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
		readonly property bool containsPress: pressed
				&& pressX >= 0 && pressX <= width
				&& pressY >= 0 && pressY <= height

		anchors {
			left: parent.left
			right: parent.right
			top: header.bottom
			topMargin: -topInset
		}

		// Expand clickable area horizontally (to delegate edges) and vertically. Adjust paddings
		// by the same amount to fit the content within the background.
		topInset: Theme.geometry_button_touch_verticalMargin
		bottomInset: Theme.geometry_button_touch_verticalMargin
		leftInset: Theme.geometry_controlCard_button_margins
		rightInset: Theme.geometry_controlCard_button_margins
		topPadding: topInset
		bottomPadding: bottomInset
		leftPadding: leftInset
		rightPadding: rightInset

		focusPolicy: Qt.NoFocus // do not focus when clicked, as this control has no edit mode

		// Show as checked, when pressing or backend indicates it is pressed
		checked: momentaryState.expectedValue === 1
			// Or when waiting for a release to be synced, else the button text flickers between
			// "On" and "Pressed" on Wasm when there is a delay between release and sync.
			|| momentaryState.busy

		// Only show the press effect when the backend has written the state succesfully.
		pressEffectRunning: momentaryState.dataItem.value === 1

		down: pressed || checked

		onContainsPressChanged: {
			if (containsPress) {
				momentaryState.setStateValue(1)
			} else {
				// Set State=0 as soon as the press moves outside of the button. Otherwise, if the
				// user drags outside and triggers a drag in the Switch Pane flickable, the events
				// move to the flickable and the touch release will not turn the button off.
				momentaryState.setStateValue(0)
			}
		}

		SettingSync {
			id: momentaryState

			property int _lastWrittenState: -1

			function setStateValue(v) {
				writeValue(v)
				_lastWrittenState = v
			}

			dataItem: VeQuickItem {
				uid: root.switchableOutput.uid + "/State"
			}

			Component.onDestruction: {
				// If the button is destroyed before the mouse release, write 0 to force a return to
				// the "off" state in the backend.
				if (_lastWrittenState === 1) {
					writeValue(0)
				}
			}
		}
	}
}
