/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

MiniSlider {
	id: root

	required property SwitchableOutput switchableOutput

	// True if the slider value is being changed by the user (either by touch or key press)
	readonly property bool dragging: pressed || _valueChangeKeyPressed
	property bool _valueChangeKeyPressed

	// Override these functions if the displayed value is different from the backend value.
	property var fromDisplayValue: (v) => { return v }
	property var toDisplayValue: (v) => { return v }

	// The number of decimals in the /StepSize value. Use this to determine the number of decimals
	// to be used when showing the selected value.
	readonly property int stepSizeDecimalCount: stepSizeItem.valid
			? stepSizeItem.value.toString().split(".")[1]?.length ?? 0
			: 0

	// Reads the slider value from the output. By default, this reads from the /Dimming path.
	property real sourceValue: switchableOutput.dimming

	// Writes the current slider value to the output. By default, this writes to the /Dimming path.
	property var updateValueToSource: (v) => { switchableOutput.setDimming(v) }

	from: dimmingMinItem.valid ? toDisplayValue(dimmingMinItem.value) : 0
	to: dimmingMaxItem.valid ? toDisplayValue(dimmingMaxItem.value) : 100
	stepSize: stepSizeItem.valid ? toDisplayValue(stepSizeItem.value) : 1

	onDraggingChanged: {
		if (dragging) {
			// While the user is controlling the handle, do not move the handle if any value updates
			//  are received from the backend.
			delayedSliderUpdate.stop()
		} else {
			// When the handle is released, pause while the slider value is written to the backend
			// (via the onMoved handler) to wait for the backend to get the updated value, before
			// syncing the backend value back to the slider, else the handle will briefly jump back
			// to the old backend value before updating to the new one.
			dimmingValue.syncBackendValueToSlider()
		}
	}

	onMoved: {
		dimmingValue.writeValue(fromDisplayValue(value))
	}

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Up:
		case Qt.Key_Down:
			// When this control has focus, prevent up/down from moving the focus elsewhere.
			event.accepted = true
			return
		case Qt.Key_Left:
		case Qt.Key_Right:
			_valueChangeKeyPressed = true
			break
		}
		event.accepted = false
	}
	Keys.onReleased: (event) => {
		if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
			_valueChangeKeyPressed = false
		}
		event.accepted = false
	}
	KeyNavigationHighlight.active: root.activeFocus

	VeQuickItem {
		id: dimmingMaxItem
		uid: root.switchableOutput.uid + "/Settings/DimmingMax"
	}
	VeQuickItem {
		id: dimmingMinItem
		uid: root.switchableOutput.uid + "/Settings/DimmingMin"
	}
	VeQuickItem {
		id: stepSizeItem
		uid: root.switchableOutput.uid + "/Settings/StepSize"
	}

	SettingSync {
		id: dimmingValue

		// Update the slider value to the backend value.
		function syncBackendValueToSlider() {
			// If user has interacted with the slider to change the value, delay briefly
			// before syncing the slider to the backend value, else this may be done while
			// user changes are still being written.
			if (busy || root.dragging || delayedSliderUpdate.running) {
				delayedSliderUpdate.restart()
			} else {
				root.value = root.toDisplayValue(backendValue)
			}
		}

		backendValue: root.sourceValue
		onUpdateToBackend: (value) => { root.updateValueToSource(value) }
		onBackendValueChanged: syncBackendValueToSlider()
		onBusyChanged: if (!busy) syncBackendValueToSlider()
	}

	// When the slider is released, wait a second for the user value to sync to the backend,
	// else the user will release the slider and then immediately see it jump several times
	// as the backend catches up to the last written value.
	Timer {
		id: delayedSliderUpdate
		interval: 1000
		onTriggered: dimmingValue.syncBackendValueToSlider()
	}
}
