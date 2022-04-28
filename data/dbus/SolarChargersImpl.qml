/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var veDBus

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

	function _updateYieldHistory(dayToUpdate) {
		let modelWasEmpty = Global.solarChargers.yieldHistory.count === 0

		let maxHistoryCount = 0
		let charger
		let i
		for (i = 0; i < chargerObjects.count; ++i) {
			charger = chargerObjects.objectAt(i)
			if (charger) {
				maxHistoryCount = Math.max(maxHistoryCount, charger.yieldHistoryObjects.count)
			}
		}

		// day 0 = today, day 1 = one day ago, etc.
		for (let day = 0; day < maxHistoryCount; ++day) {
			let dailyYield = 0
			for (i = 0; i < chargerObjects.count; ++i) {
				charger = chargerObjects.objectAt(i)
				if (charger) {
					const historyObject = charger.yieldHistoryObjects.objectAt(day)
					if (historyObject) {
						dailyYield += (historyObject.value || 0)
					}
				}
			}
			if (day == 0) {
				Global.solarChargers.yieldHistory.maximum = dailyYield
			} else {
				Global.solarChargers.yieldHistory.maximum = Math.max(
						Global.solarChargers.yieldHistory.maximum, dailyYield)
			}
			if (modelWasEmpty || day === dayToUpdate) {
				Global.solarChargers.yieldHistory.setYield(day, dailyYield)
			}
		}
	}

	// AC power is the total power from Ac/PvOnGrid, Ac/PvOnGenset and Ac/PvOnOutput.
	property Instantiator acPvMonitor: Instantiator {
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
			Global.solarChargers.acPower = p
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

	property VeQuickItem veDcPower: VeQuickItem {
		uid: "dbus/com.victronenergy.system/Dc/Pv/Power"
		onValueChanged: Global.solarChargers.dcPower = value === undefined ? NaN : value
	}

	property Connections veDBusConn: Connections {
		target: veDBus
		function onChildIdsChanged() { Qt.callLater(_getSolarChargers) }
	}

	property Instantiator chargerObjects: Instantiator {
		model: _solarChargers

		delegate: QtObject {
			id: solarCharger

			property real power
			property real voltage

			property ListModel trackers: ListModel {}

			property string _dbusUid: modelData

			function _updateTotal(chargerProperty, trackerProperty) {
				let total = NaN
				for (let i = 0; i < _trackerObjects.count; ++i) {
					const trackerObject = _trackerObjects.objectAt(i)
					const value = trackerObject[trackerProperty].value
					if (!isNaN(value)) {
						if (isNaN(total)) {
							total = 0
						}
						total += value
					}
				}
				solarCharger[chargerProperty] = total
			}

			property Instantiator yieldHistoryObjects: Instantiator {
				// Yield for each previous day, in kwh
				delegate: VeQuickItem {
					// uid is e.g. com.victronenergy.solarcharger.tty0/History/Daily/<day>/Yield
					uid: _dbusUid ? "dbus/" + _dbusUid + "/History/Daily/" + model.index + "/Yield" : ""
					onValueChanged: Qt.callLater(root._updateYieldHistory, model.index)
				}
			}
			property var _veHistoryCount: VeQuickItem {
				uid: _dbusUid ? "dbus/" + _dbusUid + "/History/Overall/DaysAvailable" : ""
				onValueChanged: {
					if (value !== undefined) {
						yieldHistoryObjects.model = value
					}
				}
			}

			property var _veNrOfTrackers: VeQuickItem {
				uid: _dbusUid ? "dbus/" + _dbusUid + "/NrOfTrackers" : ""
				onValueChanged: {
					if (value !== undefined) {
						_trackerObjects.model = value
					}
				}
			}

			property Instantiator _trackerObjects: Instantiator {
				delegate: QtObject {
					id: tracker

					// When there is only one tracker, use these paths:
					// /Yield/Power      <- PV array power (Watts).
					// /Pv/V             <- PV array voltage, path exists only for single tracker product (all common MPPTs)
					// When there are multiple trackers, use these paths:
					// /Pv/x/P           <- PV array power from tracker no. x+1.
					// /Pv/x/V           <- PV array voltage from tracker x+1
					property var vePower: VeQuickItem {
						uid: _dbusUid
							 ? _trackerObjects.count === 1
							   ? "dbus/" + _dbusUid + "/Yield/Power"
							   : "dbus/" + _dbusUid + "/Pv/" + model.index + "/P"
							 : ""
						onValueChanged: solarCharger._updateTotal("power", "vePower")
					}
					property var veVoltage: VeQuickItem {
						uid: _dbusUid
							 ? _trackerObjects.count === 1
							   ? "dbus/" + _dbusUid + "/Pv/V"
							   : "dbus/" + _dbusUid + "/Pv/" + model.index + "/V"
							 : ""
						onValueChanged: solarCharger._updateTotal("voltage", "veVoltage")
					}

					Component.onCompleted: {
						solarCharger.trackers.append({ solarTracker: tracker })
					}

					Component.onDestruction: {
						const index = Utils.findIndex(solarCharger.trackers, tracker)
						if (index >= 0) {
							solarCharger.trackers.remove(index)
						}
					}
				}
			}

			Component.onCompleted: {
				Global.solarChargers.addCharger(solarCharger)
			}

			Component.onDestruction: {
				const index = Utils.findIndex(Global.solarChargers.model, solarCharger)
				if (index >= 0) {
					Global.solarChargers.removeCharger(index)
				}
			}
		}
	}

	Component.onCompleted: {
		_getSolarChargers()
	}
}
