/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Writes a value to a setting, and indicates whether the new value has been written.
*/
QtObject {
	id: root

	// The value expected from the backend.
	required property real backendValue

	// True if a value has been written to the backend, and the backend is not yet in sync.
	readonly property bool busy: _maxBusyTimer.running && backendValue !== _pendingValue

	// If busy=true, this is the value that was written (but not yet present in the backend),
	// otherwise this is the backend value.
	readonly property real expectedValue: busy ? _pendingValue : backendValue

	property real _pendingValue: NaN

	signal updateToBackend(real value)
	signal timeout()

	// Note, it is valid to write a value that is the same as the pending or backend value:
	// - User might want to force a write of the same value, if the previous write did not succeed.
	// - There may be another write in progress on the backend, and so it will change to that other
	// value, then to this new value when the request is received.
	function writeValue(v) {
		_pendingValue = v
		_maxBusyTimer.restart()
		updateToBackend(v)
	}

	onBackendValueChanged: {
		if (_pendingValue === backendValue) {
			_maxBusyTimer.stop()
		}
	}

	// Avoid a deadlock situation where the backend never updates to the expected value. Possible
	// reasons include:
	// - the pending write did not occur due to a write by another user via VRM
	// - the backend was unable (or refused) to update the value
	// - some latency when changing values via VRM
	readonly property Timer _maxBusyTimer: Timer {
		// Timeout is 3 sec over VRM, or 0.5 sec on Wasm local and on-screen device.
		interval: BackendConnection.vrm ? 3000 : 500
		onTriggered: root.timeout()
	}
}
