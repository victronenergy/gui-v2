/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {}

	property real voltage
	property real power

	property string _dbusUid
	property var _solarTrackers: []

	function _getSolarChargers() {
		if (_dbusUid.length > 0) {
			return
		}
		const childIds = veDBus.childIds
		for (let i = 0; i < childIds.length; ++i) {
			let childId = childIds[i]
			if (childId.startsWith('com.victronenergy.solarcharger.')) {
				_dbusUid = childId
				return
			}
		}
	}

	function _getTrackers() {
		const childIds = vePvConfig.childIds
		let trackerIds = []
		for (let i = 0; i < childIds.length; ++i) {
			let childId = childIds[i]
			// TODO test this where multiple trackers are present
			if (!isNaN(childId)) {
				trackerIds.push(childId)
			}
		}

		if (Utils.arrayCompare(_solarTrackers, trackerIds)) {
			_solarTrackers = trackerIds
		}
	}

	VeQuickItem {
		id: veVoltage
		uid: _dbusUid ? "dbus/" + _dbusUid + "/Pv/V" : ""
		onStateChanged: {
			if (state == VeQItem.Synchronized) {
				// This dbus path exists; docs say this means there is only one tracker
				root.model.append({ solarTracker: singleTracker })
			} else if (state == VeQItem.Offline) {
				// This dbus path does not exist; docs say this means there are multiple trackers,
				// so initiate the bindings to find the child objects.
				console.log("Found solar charger with multiple trackers")
				vePvConfig.uid = "dbus/" + _dbusUid + "/Pv"
			}
		}

		onValueChanged: root.voltage = value === undefined ? -1 : value
	}

	VeQuickItem {
		id: veYield
		uid: _dbusUid ? "dbus/" + _dbusUid + "/Yield/Power" : ""
		onValueChanged: root.power = value === undefined ? -1 : value
	}

	Connections {
		target: veDBus
		function onChildIdsChanged() { Qt.callLater(_getSolarChargers) }
		Component.onCompleted: _getSolarChargers()
	}

	VeQuickItem {
		id: vePvConfig
	}

	Connections {
		target: vePvConfig
		function onChildIdsChanged() { Qt.callLater(_getTrackers) }
		Component.onCompleted: _getTrackers()
	}

	// Used when there is only a single solar tracker. Properties must be same as those in the
	// multi-tracker model.
	QtObject {
		id: singleTracker

		property real voltage: root.voltage
		property real power: root.power
	}

	Instantiator {
		model: _solarTrackers

		delegate: QtObject {
			id: solarTracker

			property string uid: modelData
			property string dbusUid: "dbus/" + _dbusUid + "/Pv/" + solarTracker.uid

			property real voltage
			property real power

			property bool _valid
			on_ValidChanged: {
				const index = Utils.findIndex(root.model, inverter)
				if (_valid && index < 0) {
					root.model.append({ inverter: inverter })
				} else if (!_valid && index >= 0) {
					root.model.remove(index)
				}
			}

			property VeQuickItem _voltage: VeQuickItem {
				uid: dbusUid ? dbusUid + "/V" : ""
				onValueChanged: {
					_valid |= (value === undefined)
					solarTracker.voltage = value === undefined ? -1 : value
				}
			}
			property VeQuickItem _power: VeQuickItem {
				uid: dbusUid ? dbusUid + "/P" : ""
				onValueChanged: {
					_valid |= (value === undefined)
					solarTracker.power = value === undefined ? -1 : value
				}
			}
		}
	}
}
