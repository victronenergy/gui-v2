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
	// This is only set for MQTT backends, where there is a noticeable latency in syncing values.
	readonly property bool busy: BackendConnection.type === BackendConnection.MqttSource && _busy

	// If busy=true, this is the value that was written (but not yet present in the backend),
	// otherwise this is the backend value.
	readonly property real expectedValue: busy ? _pendingValue : backendValue

	property real _pendingValue: NaN
	property bool _busy

	signal updateToBackend(real value)

	function writeValue(v) {
		if (_pendingValue !== v) {
			_pendingValue = v
			_busy = true

			// It is valid to write the same value as the current backend value, if there is
			// another write in progress (i.e. if it will change to another value, then back to
			// this current backend value).
			if (backendValue === v) {
				_maxBusyTimer.restart()
			}

			updateToBackend(v)
		}
	}

	function _reset() {
		_busy = false
		_pendingValue = NaN
	}

	onBackendValueChanged: {
		_maxBusyTimer.stop()
		if (backendValue === _pendingValue) {
			_reset()
		}
	}

	// Avoid a deadlock situation where the backend never updates to the expected value - e.g. if
	// the pending write did not occur due to a write by another user via VRM.
	readonly property Timer _maxBusyTimer: Timer {
		interval: 3000
		onTriggered: root._reset()
	}
}
