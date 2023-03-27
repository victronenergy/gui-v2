/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

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
	property int sourceType: BackendConnection.type

	property var value: sourceObject ? sourceObject.value : undefined
	readonly property bool valid: value !== undefined

	property bool hasMin
	property bool hasMax
	property var min: hasMin && sourceObject ? sourceObject.min : undefined
	property var max: hasMax && sourceObject ? sourceObject.max : undefined

	property var _dbusImpl
	property var _mqttImpl
	property var _mqttUidHelper
	property Component _mqttUidHelperComponent: Component {
		QtObject {
			readonly property string mqttUid: root.source.startsWith("mqtt/") ? root.source : _uidConverter.mqttUid

			readonly property SingleUidHelper _uidConverter: SingleUidHelper {
				dbusUid: root.source.length === 0 || root.source.startsWith("mqtt/")
						 ? ""
						 : (root.source.startsWith("dbus/") ? root.source : "dbus/" + root.source)
			}
		}
	}

	function setValue(v) {
		if (sourceObject) {
			sourceObject.setValue(v)
		} else {
			console.warn("Set value() failed, no sourceObject for source", source)
		}
	}

	function _dbusImplStatusChanged() {
		if (!_dbusImpl) {
			return
		}
		if (_dbusImpl.status === Component.Error) {
			console.warn("Unable to load DataPointDBusImpl.qml", _dbusImpl.errorString())
		} else if (_dbusImpl.status === Component.Ready) {
			_dbusImpl.statusChanged.disconnect(_dbusImplStatusChanged)
			_createDBusImpl()
		}
	}

	function _mqttImplStatusChanged() {
		if (!_mqttImpl) {
			return
		}
		if (_mqttImpl.status === Component.Error) {
			console.warn("Unable to load DataPointMqttImpl.qml", _mqttImpl.errorString())
		} else if (_mqttImpl.status === Component.Ready) {
			_mqttImpl.statusChanged.disconnect(_mqttImplStatusChanged)
			_createMqttImpl()
		}
	}

	function _createDBusImpl() {
		if (!_dbusImpl || _dbusImpl.status !== Component.Ready) {
			console.warn("Cannot create object from component", _dbusImpl ? _dbusImpl.url : "")
			return
		}
		if (sourceObject) {
			sourceObject.destroy()
			sourceObject = null
		}
		sourceObject = _dbusImpl.createObject(root, { uid: Qt.binding(function() { return root.source.startsWith("dbus/") ? root.source : "dbus/" + root.source }) })
		if (!sourceObject) {
			console.warn("Failed to create object from DataPointDBusImpl.qml", _dbusImpl.errorString())
			return
		}
	}

	function _createMqttImpl() {
		if (!_mqttImpl || _mqttImpl.status !== Component.Ready) {
			console.warn("Cannot create object from component", _mqttImpl ? _mqttImpl.url : "")
			return
		}
		if (sourceObject) {
			sourceObject.destroy()
			sourceObject = null
		}
		sourceObject = _mqttImpl.createObject(root, { uid: Qt.binding(function() { return _mqttUidHelper.mqttUid }) })
		if (!sourceObject) {
			console.warn("Failed to create object from DataPointMqttImpl.qml", _mqttImpl.errorString())
			return
		}
	}

	function _reset() {
		if (source.length === 0) {
			return
		}
		switch (sourceType) {
		case BackendConnection.DBusSource:
			if (!_dbusImpl) {
				_dbusImpl = Qt.createComponent(Qt.resolvedUrl("DataPointDBusImpl.qml"),
						Component.Asynchronous)
			}
			if (_dbusImpl.status === Component.Loading) {
				_dbusImpl.statusChanged.connect(_dbusImplStatusChanged)
			} else if (_dbusImpl.status === Component.Ready) {
				_createDBusImpl()
			}
			break
		case BackendConnection.MqttSource:
			if (!_mqttImpl) {
				_mqttUidHelper = _mqttUidHelperComponent.createObject(root)
				_mqttImpl = Qt.createComponent(Qt.resolvedUrl("DataPointMqttImpl.qml"),
						Component.Asynchronous)
			}
			if (_mqttImpl.status === Component.Loading) {
				_mqttImpl.statusChanged.connect(_mqttImplStatusChanged)
			} else if (_mqttImpl.status === Component.Ready) {
				_createMqttImpl()
			}
			break
		case BackendConnection.MockSource:
			const comp = Qt.createComponent(Qt.resolvedUrl("DataPointMockImpl.qml"))
			sourceObject = comp.createObject(root, { "source": root.source })
			break
		default:
			console.warn("Unknown DataPoint source type:", sourceType)
			break
		}
	}

	onSourceChanged: _reset()
	onSourceTypeChanged: _reset()
	Component.onCompleted: _reset()
	Component.onDestruction: {
		// As a precaution, if asynchronous component creation finishes after object destruction,
		// ensure the statusChanged() handlers are not called.
		if (_dbusImpl) {
			_dbusImpl.statusChanged.disconnect(_dbusImplStatusChanged)
			_dbusImpl = null
		}
		if (_mqttImpl) {
			_mqttImpl.statusChanged.disconnect(_mqttImplStatusChanged)
			_mqttImpl = null
		}
	}
}
