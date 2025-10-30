/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

SettingSync {
	id: root

	required property bool dragging

	signal updateSliderValue()

	// Update the slider value to the backend value.
	function _syncBackendValueToSlider() {
		// If user has interacted with the slider to change the value, delay briefly
		// before syncing the slider to the backend value, else this may be done while
		// user changes are still being written.
		if (busy || root.dragging || _delayedSliderUpdate.running) {
			_delayedSliderUpdate.restart()
		} else {
			updateSliderValue()
		}
	}

	onBusyChanged: if (!busy) _syncBackendValueToSlider()
	onDataValueChanged: _syncBackendValueToSlider()

	onDraggingChanged: {
		if (dragging) {
			// While the user is controlling the handle, do not move the handle if any value updates
			// are received from the backend.
			_delayedSliderUpdate.stop()
		} else {
			// When the handle is released, pause while the slider value is written to the backend
			// (via the onMoved handler) to wait for the backend to get the updated value, before
			// syncing the backend value back to the slider, else the handle will briefly jump back
			// to the old backend value before updating to the new one.
			_syncBackendValueToSlider()
		}
	}

	// When the slider is released, wait a second for the user value to sync to the backend,
	// else the user will release the slider and then immediately see it jump several times
	// as the backend catches up to the last written value.
	readonly property Timer _delayedSliderUpdate: Timer {
		interval: 1000
		onTriggered: root._syncBackendValueToSlider()
	}
}
