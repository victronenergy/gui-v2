/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	// Model of all solar trackers for all solar chargers
	property ListModel model: ListModel {}

	// Overall solar power
	readonly property real power: isNaN(acPower) && isNaN(dcPower)
			? NaN
			: (isNaN(acPower) ? 0 : acPower) + (isNaN(dcPower) ? 0 : dcPower)
	property real acPower: NaN
	readonly property real dcPower: veDcPower.value === undefined ? NaN : veDcPower.value

	property var yieldHistory: []

	property var _solarChargers: []

	onPowerChanged: {
		// Set max tracker power based on total number of trackers
		Utils.updateMaximumValue("solarTracker.power", power / Math.max(1, model.count))
	}

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
			Utils.updateMaximumValue("dailySolarYield", dailyYield)
			_yieldHistory.push(dailyYield || 0)
		}
		if (Utils.arrayCompare(_yieldHistory, yieldHistory) !== 0) {
			yieldHistory = _yieldHistory
		}
	}

	// AC power is the total power from Ac/PvOnGrid, Ac/PvOnGenset and Ac/PvOnOutput.
	Instantiator {
		id: acPvMonitor

		function updateAcPower() {
			let p = NaN
			for (let i = 0; i < count; ++i) {
				const value = objectAt(i).power
				if (value !== undefined) {
					if (isNaN(p)) {
						p = 0
					}
					p += value
				}
			}
			root.acPower = p
		}

		model: [
			"dbus/com.victronenergy.system/Ac/PvOnGrid",
			"dbus/com.victronenergy.system/Ac/PvOnGenset",
			"dbus/com.victronenergy.system/Ac/PvOnOutput"
		]

		delegate: QtObject {
			id: acPvDelegate

			readonly property string dbusUid: modelData
			property real power: NaN

			function updatePower() {
				let p = NaN
				for (let i = 0; i < pvPhases.count; ++i) {
					const value = pvPhases.objectAt(i).value
					if (value !== undefined) {
						if (isNaN(p)) {
							p = 0
						}
						p += value
					}
				}
				power = p
				acPvMonitor.updateAcPower()
			}

			property var vePhaseCount: VeQuickItem {
				uid: acPvDelegate.dbusUid + "/NumberOfPhases"
				onValueChanged: {
					const phaseCount = value === undefined ? 0 : value
					if (pvPhases.count !== phaseCount) {
						pvPhases.model = phaseCount
					}
				}
			}

			// Each Ac/PvOnX uid has 1-3 phases with power, e.g. Ac/PvOnGrid/L1/Power, Ac/PvOnGrid/L2/Power
			property var pvPhases: Instantiator {
				delegate: VeQuickItem {
					uid: acPvDelegate.dbusUid + "/L" + (model.index + 1) + "/Power"
					onValueChanged: acPvDelegate.updatePower()
				}
			}
		}
	}

	VeQuickItem {
		id: veDcPower

		uid: "dbus/com.victronenergy.system/Dc/Pv/Power"
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

			property var _veYield: VeQuickItem {
				uid: _dbusUid ? "dbus/" + _dbusUid + "/Yield/Power" : ""
				onValueChanged: solarCharger.power = value === undefined ? 0 : value
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
				property real power: solarCharger.power
			}

			property var _trackersInstantiator: Instantiator {
				model: _solarTrackers

				delegate: QtObject {
					id: solarTracker

					property string uid: modelData
					property string dbusUid: "dbus/" + _dbusUid + "/Pv/" + solarTracker.uid

					// Power for this tracker only
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
