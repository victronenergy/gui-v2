/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	// Valid 'source' values are:
	// - dbus paths, e.g. 'com.victronenergy.blah/path/to/value'
	// - as above, but with as full dbus uid, e.g. 'dbus/com.victronenergy.blah/path/to/value'
	// - full mqtt uid, e.g. 'mqtt/blah/device-id/path/to/value'
	// Note that dbus and mqtt uids should only be used when the application is using their
	// respective backend connection types. If a mqtt uid is used on a dbus connection, for
	// example, the DataPoint would not produce a valid value.
	property string source
	property var sourceObject

	readonly property var value: sourceObject ? sourceObject.value : undefined
	readonly property bool valid: value !== undefined

	property bool hasMin
	property bool hasMax
	readonly property var min: hasMin && sourceObject ? sourceObject.min : undefined
	readonly property var max: hasMax && sourceObject ? sourceObject.max : undefined
	property bool invalidate: true

	property Component _dbusComponent : Component {
		VeQuickItem {
			uid: root.source.startsWith("dbus/") ? root.source : "dbus/" + root.source
			invalidate: root.invalidate

			onInvalidateChanged: root.invalidate = invalidate
		}
	}

	property Component _mqttComponent : Component {
		VeQuickItem {
			readonly property string mqttUid: root.source.startsWith("mqtt/") ? root.source : _uidConverter.mqttUid

			readonly property SingleUidHelper _uidConverter: SingleUidHelper {
				dbusUid: root.source.length === 0 || root.source.startsWith("mqtt/")
						 ? ""
						 : (root.source.startsWith("dbus/") ? root.source : "dbus/" + root.source)
			}

			uid: mqttUid
			invalidate: root.invalidate

			onInvalidateChanged: root.invalidate = invalidate
		}
	}

	property Component _mockComponent : Component {
		QtObject {
			id: root

			property string source: root.source
			property var value: Global.mockDataSimulator ? Global.mockDataSimulator.mockDataValues[source] : undefined
			property real min: 0
			property real max: 100
			property bool invalidate: root.invalidate

			function setValue(v) {
				value = v
			}

			function getValue(force) {
				// no-op
			}

			onInvalidateChanged: root.invalidate = invalidate
		}
	}

	function setValue(v) {
		if (sourceObject) {
			sourceObject.setValue(v)
		} else {
			console.warn("setValue() failed, no sourceObject for source", source)
		}
	}

	function refresh() {
		if (sourceObject) {
			sourceObject.getValue(true)
		} else {
			console.warn("refresh() failed, no sourceObject for source", source)
		}
	}

	function _reset() {
		if (source.length === 0) {
			return
		}
		if (sourceObject) {
			sourceObject.destroy()
			sourceObject = null
		}
		// TODO: maybe use incubateObject() in future if synchronous construction of sourceObject
		// takes too long.
		switch (BackendConnection.type) {
		case BackendConnection.DBusSource:
			sourceObject = _dbusComponent.createObject(root)
			break
		case BackendConnection.MqttSource:
			sourceObject = _mqttComponent.createObject(root)
			break
		case BackendConnection.MockSource:
			sourceObject = _mockComponent.createObject(root)
			break
		default:
			console.warn("Unknown DataPoint source type:", BackendConnection.type)
			break
		}
	}

	onSourceChanged: _reset()
	Component.onCompleted: _reset()
}
