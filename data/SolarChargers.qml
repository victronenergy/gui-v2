/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	// Model of all solar trackers for all solar chargers
	property ListModel model: ListModel {}

	// Overall voltage and power for all chargers
	property real voltage
	property real power
	property var yieldHistory: []

	property var _solarChargers: []

	function _getSolarChargers() {
		const childIds = veDBus.childIds

		let solarChargerIds = []
		for (let i = 0; i < childIds.length; ++i) {
			let id = childIds[i]
			if (id.startsWith('com.victronenergy.solarcharger.')) {
				solarChargerIds.push(id)
			}
		}

		if (Utils.arrayCompare(_solarChargers, solarChargerIds) !== 0) {
			_solarChargers = solarChargerIds
		}
	}

	function _updateTotalVoltage() {
		let v = 0
		for (let i = 0; i < _chargersInstantiator.count; ++i) {
			v += _chargersInstantiator.objectAt(i).voltage
		}
		voltage = v
	}

	function _updateTotalPower() {
		let p = 0
		for (let i = 0; i < _chargersInstantiator.count; ++i) {
			p += _chargersInstantiator.objectAt(i).power
		}
		power = p

		// Set max tracker power based on total number of trackers
		Utils.updateMaximumValue("solarTracker.power", power / Math.max(1, model.count))
	}

	function _updateYieldHistory() {
		// Each charger has a yield total for each day. Create a total yield history containing the
		// sum of the yield for each day across all chargers.
		let totalDailyYields = {}
		let maxHistoryCount = 0
		let i = 0

		for (i = 0; i < _chargersInstantiator.count; ++i) {
			let charger = _chargersInstantiator.objectAt(i)
			let dailyYields = charger.dailyYields
			maxHistoryCount = Math.max(maxHistoryCount, charger.historyCount)
			for (let historyId in dailyYields) {
				totalDailyYields[historyId] = dailyYields[historyId] + (totalDailyYields[historyId] || 0)
			}
		}

		// Move sums into an ordered list, assuming history ids are 0,1,2 etc
		let _yieldHistory = []
		for (i = 0; i < maxHistoryCount; ++i) {
			let dailyYield = totalDailyYields[i + ""]
			_yieldHistory.push(dailyYield || 0)
		}
		if (Utils.arrayCompare(_yieldHistory, yieldHistory) !== 0) {
			yieldHistory = _yieldHistory
		}
	}

	Connections {
		target: veDBus
		function onChildIdsChanged() { Qt.callLater(_getSolarChargers) }
		Component.onCompleted: _getSolarChargers()
	}

	Instantiator {
		id: _chargersInstantiator

		model: _solarChargers

		delegate: QtObject {
			id: solarCharger

			// Overall values for this charger
			property real voltage
			property real power
			property var dailyYields: ({})
			readonly property int historyCount: _historyIds.length

			property string _dbusUid: modelData
			property var _solarTrackers: []
			property var _historyIds: []

			function _getTrackers() {
				const childIds = _vePvConfig.childIds
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

			function _getHistory() {
				const childIds = _veHistory.childIds
				let historyIds = []
				for (let i = 0; i < childIds.length; ++i) {
					let childId = childIds[i]
					if (!isNaN(childId)) {
						historyIds.push(childId)
					}
				}

				if (Utils.arrayCompare(_historyIds, historyIds)) {
					_historyIds = historyIds
				}
			}

			function _updateDailyYields() {
				let _dailyYields = {}
				for (let i = 0; i < _historyInstantiator.count; ++i) {
					var historyItem = _historyInstantiator.objectAt(i)
					_dailyYields[historyItem.historyId] = historyItem.value
				}
				dailyYields = _dailyYields
				root._updateYieldHistory()
			}

			property var _veNrOfTrackers: VeQuickItem {
				uid: _dbusUid ? "dbus/" + _dbusUid + "/NrOfTrackers" : ""
				onValueChanged: {
					if (value !== undefined) {
						if (value === 1) {
							// When there is a single tracker, the /Pv/x paths do not exist, so
							// add a single tracker directly to the model.
							const index = Utils.findIndex(root.model, _singleTracker)
							if (index < 0) {
								root.model.append({ solarTracker: _singleTracker })
							}
						} else {
							// Initiate the bindings to find the /Pv/x child objects.
							_vePvConfig.uid = "dbus/" + _dbusUid + "/Pv"
						}
					}
				}
			}

			property var _veVoltage: VeQuickItem {
				uid: _dbusUid ? "dbus/" + _dbusUid + "/Pv/V" : ""
				onValueChanged: {
					solarCharger.voltage = value === undefined ? 0 : value
					root._updateTotalVoltage()
				}
			}

			property var _veYield: VeQuickItem {
				uid: _dbusUid ? "dbus/" + _dbusUid + "/Yield/Power" : ""
				onValueChanged: {
					solarCharger.power = value === undefined ? 0 : value
					root._updateTotalPower()
				}
			}

			property var _vePvConfig: VeQuickItem {
				id: _vePvConfig
			}

			property var _trackersUpdate: Connections {
				target: _vePvConfig
				function onChildIdsChanged() { Qt.callLater(_getTrackers) }
				Component.onCompleted: _getTrackers()
			}

			property var _veHistory: VeQuickItem {
				uid: _dbusUid ? "dbus/" + _dbusUid + "/History/Daily" : ""
			}

			property var _veHistoryUpdate: Connections {
				target: _veHistory
				function onChildIdsChanged() { Qt.callLater(_getHistory) }
				Component.onCompleted: _getHistory()
			}

			// Used when there is only a single solar tracker for this charger. Properties must be
			// same as those in the multi-tracker model.
			property var _singleTracker: QtObject {
				property real voltage: solarCharger.voltage
				property real power: solarCharger.power
			}

			property var _trackersInstantiator: Instantiator {
				model: _solarTrackers

				delegate: QtObject {
					id: solarTracker

					property string uid: modelData
					property string dbusUid: "dbus/" + _dbusUid + "/Pv/" + solarTracker.uid

					// Voltage and power for this tracker only
					property real voltage
					property real power

					property bool _valid
					on_ValidChanged: {
						const index = Utils.findIndex(root.model, solarTracker)
						if (_valid && index < 0) {
							root.model.append({ solarTracker: solarTracker })
						} else if (!_valid && index >= 0) {
							root.model.remove(index)
						}
					}

					property VeQuickItem _voltage: VeQuickItem {
						uid: dbusUid ? dbusUid + "/V" : ""
						onValueChanged: {
							_valid |= (value === undefined)
							solarTracker.voltage = value === undefined ? 0 : value
						}
					}
					property VeQuickItem _power: VeQuickItem {
						uid: dbusUid ? dbusUid + "/P" : ""
						onValueChanged: {
							_valid |= (value === undefined)
							solarTracker.power = value === undefined ? 0 : value
						}
					}
				}
			}

			property var _historyInstantiator: Instantiator {
				model: _historyIds

				delegate: VeQuickItem {
					property string historyId: modelData
					uid: _veHistory.childUId("/" + modelData + "/Yield")

					onValueChanged: if (value !== undefined) solarCharger._updateDailyYields()
				}
			}
		}
	}
}
