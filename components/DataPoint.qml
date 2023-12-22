/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

VeQuickItem {
	id: root

	// Valid 'source' values are:
	// - dbus paths, e.g. 'com.victronenergy.blah/path/to/value'
	// - as above, but with as full dbus uid, e.g. 'dbus/com.victronenergy.blah/path/to/value'
	// - full mqtt uid, e.g. 'mqtt/blah/device-id/path/to/value'
	// Note that dbus and mqtt uids should only be used when the application is using their
	// respective backend connection types. If a mqtt uid is used on a dbus connection, for
	// example, the DataPoint would not produce a valid value.
	property string source

	// Using 'valid' to be more aligned with other QML APIs
	readonly property alias valid: root.isValid

	uid: {
		if (source.length === 0) {
			return ""
		}
		switch (BackendConnection.type) {
		case BackendConnection.DBusSource:
			return root.source.startsWith("dbus/") ? root.source : "dbus/" + root.source
		case BackendConnection.MqttSource:
			return root.source.startsWith("mqtt/") ? root.source : "mqtt/" + root.source
		case BackendConnection.MockSource:
			return root.source.startsWith("mock/") ? root.source : "mock/" + root.source
		default:
			console.warn("Unknown DataPoint source type:", BackendConnection.type)
			break
		}
	}
}
