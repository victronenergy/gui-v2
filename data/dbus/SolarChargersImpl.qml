/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var veServiceIds
	onVeServiceIdsChanged: Qt.callLater(_getSolarChargers)

	property var _solarChargers: []

	function _getSolarChargers() {
		let solarChargerIds = []
		for (let i = 0; i < veServiceIds.length; ++i) {
			let id = veServiceIds[i]
			if (id.startsWith('com.victronenergy.solarcharger.')) {
				solarChargerIds.push(id)
			}
		}

		if (Utils.arrayCompare(_solarChargers, solarChargerIds) !== 0) {
			_solarChargers = solarChargerIds
		}
	}

	function _populateYieldHistory() {
		let maxHistoryCount = 0
		for (let i = 0; i < chargerObjects.count; ++i) {
			const charger = chargerObjects.objectAt(i)
			if (charger) {
				maxHistoryCount = Math.max(maxHistoryCount, charger.yieldHistoryObjects.count)
			}
		}

		// day 0 = today, day 1 = one day ago, etc.
		for (let day = 0; day < maxHistoryCount; ++day) {
			_updateYieldHistory(day)
		}
	}

	function _updateYieldHistory(dayToUpdate) {
		// Find the yield for this day across all chargers.
		let dailyYield = 0
		for (let i = 0; i < chargerObjects.count; ++i) {
			const charger = chargerObjects.objectAt(i)
			if (charger) {
				const historyObject = charger.yieldHistoryObjects.objectAt(dayToUpdate)
				if (historyObject) {
					dailyYield += (historyObject.value || 0)
				}
			}
		}

		Global.solarChargers.updateYieldHistory(dayToUpdate, dailyYield)
	}

	// AC power is the total power from Ac/PvOnGrid, Ac/PvOnGenset and Ac/PvOnOutput.
	property Instantiator acPvMonitor: Instantiator {
		function updateAcTotals() {
			let totalPower = NaN
			let totalCurrent = NaN

			for (let i = 0; i < count; ++i) {
				const acPv = objectAt(i)
				if (!!acPv) {
					for (let j = 0; j < acPv.pvPhases.count; ++j) {
						const phase = acPv.pvPhases.objectAt(j)
						if (!isNaN(phase.power)) {
							if (isNaN(totalPower)) {
								totalPower = 0
							}
							totalPower += phase.power
						}
						if (!isNaN(phase.current)) {
							if (isNaN(totalCurrent)) {
								totalCurrent = 0
							}
							totalCurrent += phase.current
						}
					}
				}
			}
			Global.solarChargers.acPower = totalPower
			Global.solarChargers.acCurrent = totalCurrent
		}

		model: [
			"dbus/com.victronenergy.system/Ac/PvOnGrid",
			"dbus/com.victronenergy.system/Ac/PvOnGenset",
			"dbus/com.victronenergy.system/Ac/PvOnOutput"
		]

		delegate: QtObject {
			id: acPvDelegate

			readonly property string dbusUid: modelData

			property var vePhaseCount: VeQuickItem {
				uid: acPvDelegate.dbusUid + "/NumberOfPhases"
				onValueChanged: {
					const phaseCount = value === undefined ? 0 : value
					if (pvPhases.count !== phaseCount) {
						pvPhases.model = phaseCount
					}
				}
			}

			// Each Ac/PvOnX uid has 1-3 phases with power and current, e.g. Ac/PvOnGrid/L1/Power,
			// Ac/PvOnGrid/L1/Current
			property var pvPhases: Instantiator {
				delegate: QtObject {
					id: phase

					property real power
					property real current

					property VeQuickItem vePower: VeQuickItem {
						uid: acPvDelegate.dbusUid + "/L" + (model.index + 1) + "/Power"
						onValueChanged: {
							phase.power = value === undefined ? NaN : value
							Qt.callLater(acPvMonitor.updateAcTotals)
						}
					}
					property VeQuickItem veCurrent: VeQuickItem {
						uid: acPvDelegate.dbusUid + "/L" + (model.index + 1) + "/Current"
						onValueChanged: {
							phase.current = value === undefined ? NaN : value
							Qt.callLater(acPvMonitor.updateAcTotals)
						}
					}
				}
			}
		}
	}

	property VeQuickItem veDcPower: VeQuickItem {
		uid: "dbus/com.victronenergy.system/Dc/Pv/Power"
		onValueChanged: Global.solarChargers.dcPower = value === undefined ? NaN : value
	}

	property VeQuickItem veDcCurrent: VeQuickItem {
		uid: "dbus/com.victronenergy.system/Dc/Pv/Current"
		onValueChanged: Global.solarChargers.dcCurrent = value === undefined ? NaN : value
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
				model: undefined    // ensure delegates are not created before history model is set
				delegate: VeQuickItem {
					// uid is e.g. com.victronenergy.solarcharger.tty0/History/Daily/<day>/Yield
					uid: _dbusUid ? "dbus/" + _dbusUid + "/History/Daily/" + model.index + "/Yield" : ""
					onValueChanged: {
						if (value === undefined) {
							return
						}
						if (Global.solarChargers.yieldHistory.length < _veHistoryCount.value) {
							Qt.callLater(root._populateYieldHistory)    // batch the initial calls to populate the model
						} else {
							root._updateYieldHistory(model.index)
						}
					}
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
}
