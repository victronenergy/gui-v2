/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

MiniSlider {
	id: root

	required property SwitchableOutput switchableOutput
	property alias valueItem: valueItem.uid
	property int sourceUnit
	property int displayUnit

	// True if the slider value is being changed by the user (either by touch or key press)
	readonly property bool dragging: pressed || _valueChangeKeyPressed
	property bool _valueChangeKeyPressed

	from: dimmingMinItem.valid ? dimmingMinItem.value : 0
	to: dimmingMaxItem.valid ? dimmingMaxItem.value : 100
	stepSize: stepSizeItem.valid ? stepSizeItem.value : 1

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
			valueSync.syncBackendValueToSlider()
		}
	}

	onMoved: {
		valueItem.setValue(value)
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
		id: valueItem
		uid: root.switchableOutput.uid + "/Dimming"
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
		onValueChanged: valueSync.syncBackendValueToSlider()
	}
	VeQuickItem {
		id: dimmingMaxItem
		uid: root.switchableOutput.uid + "/Settings/DimmingMax"
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}
	VeQuickItem {
		id: dimmingMinItem
		uid: root.switchableOutput.uid + "/Settings/DimmingMin"
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}
	VeQuickItem {
		id: stepSizeItem
		uid: root.switchableOutput.uid + "/Settings/StepSize"
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}

	SettingSync {
		id: valueSync

		// Update the slider value to the backend value.
		function syncBackendValueToSlider() {
			// If user has interacted with the slider to change the value, delay briefly
			// before syncing the slider to the backend value, else this may be done while
			// user changes are still being written.
			if (busy || root.dragging || delayedSliderUpdate.running) {
				delayedSliderUpdate.restart()
			} else {
				root.value = dataItem.value ?? 0
			}
		}

		dataItem: valueItem
		onBusyChanged: if (!busy) syncBackendValueToSlider()
	}

	// When the slider is released, wait a second for the user value to sync to the backend,
	// else the user will release the slider and then immediately see it jump several times
	// as the backend catches up to the last written value.
	Timer {
		id: delayedSliderUpdate
		interval: 1000
		onTriggered: valueSync.syncBackendValueToSlider()
	}
}
