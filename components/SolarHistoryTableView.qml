/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	property SolarHistory solarHistory
	property var dayRange: [0, 1]   // exclusive range: [first day, last day + 1]

	property bool smallTextMode
	property bool summaryOnly
	property real minimumHeight: NaN // TODO, for single-tracker mode, stretch the spacer

	width: parent ? parent.width : 0
	bottomPadding: solarDetailBox.visible ? Theme.geometry_solarDetailBox_verticalMargin : 0

	function _trackerHistoryTotal(role, trackerIndex) {
		let totalValue = NaN
		if (!solarHistory.ready) {
			return totalValue
		}
		for (let day = dayRange[0]; day < dayRange[1]; ++day) {
			const history = trackerIndex === undefined
					? root.solarHistory.dailyHistory(day)
					: root.solarHistory.dailyTrackerHistory(day, trackerIndex)
			if (history) {
				totalValue = Units.sumRealNumbers(totalValue, history[role])
			}
		}
		return totalValue
	}

	function _trackerHistoryMin(role, trackerIndex) {
		let minValue = NaN
		if (!solarHistory.ready) {
			return minValue
		}
		for (let day = dayRange[0]; day < dayRange[1]; ++day) {
			const history = trackerIndex === undefined
					? root.solarHistory.dailyHistory(day)
					: root.solarHistory.dailyTrackerHistory(day, trackerIndex)
			if (history) {
				const value = history[role]
				if (!isNaN(value)) {
					minValue = isNaN(minValue) ? value : Math.min(minValue, value)
				}
			}
		}
		return minValue
	}

	function _trackerHistoryMax(role, trackerIndex) {
		let maxValue = NaN
		if (!solarHistory.ready) {
			return maxValue
		}
		for (let day = dayRange[0]; day < dayRange[1]; ++day) {
			const history = trackerIndex === undefined
					? root.solarHistory.dailyHistory(day)
					: root.solarHistory.dailyTrackerHistory(day, trackerIndex)
			if (history) {
				const value = history[role]
				if (!isNaN(value)) {
					maxValue = isNaN(maxValue) ? value : Math.max(maxValue, value)
				}
			}
		}
		return maxValue
	}

	QuantityTableSummary {
		id: tableSummary

		width: parent.width
		bodyFontSize: root.smallTextMode ? Theme.font_size_body2 : Theme.font_size_body3
		summaryModel: [
			{ text: CommonWords.yield_kwh, unit: VenusOS.Units_Energy_KiloWattHour },
			  //% "Max Voltage"
			{ text: qsTrId("charger_history_max_voltage"), unit: VenusOS.Units_Volt_DC },
			  //% "Max Power"
			{ text: qsTrId("charger_history_max_power"), unit: VenusOS.Units_Watt },
		]
		bodyHeaderText: CommonWords.total
		bodyModel: QuantityObjectModel {
			id: summaryModel

			readonly property real totalYield: root._trackerHistoryTotal("yieldKwh")
			readonly property real maxVoltage: root._trackerHistoryMax("maxPvVoltage")
			readonly property real maxPower: root._trackerHistoryMax("maxPower")

			QuantityObject { object: summaryModel; key: "totalYield"; unit: VenusOS.Units_Energy_KiloWattHour }
			QuantityObject { object: summaryModel; key: "maxVoltage"; unit: VenusOS.Units_Volt_DC }
			QuantityObject { object: summaryModel; key: "maxPower"; unit: VenusOS.Units_Watt }
		}
	}

	QuantityTable {
		id: trackerTable

		width: parent.width
		bottomMargin: Theme.geometry_quantityTable_bottomMargin
		visible: !root.summaryOnly
		metricsFontSize: tableSummary.metricsFontSize
		columnSpacing: tableSummary.columnSpacing

		// Table is only shown when there are multiple trackers.
		model: root.solarHistory.trackerCount === 1 ? 0 : root.solarHistory.trackerCount
		delegate: QuantityTable.TableRow {
			id: tableRow

			preferredVisible: solarTracker.enabled
			headerText: solarTracker.name
			model: QuantityObjectModel {
				id: rowModel

				readonly property real totalYield: root._trackerHistoryTotal("yieldKwh", tableRow.index)
				readonly property real maxVoltage: root._trackerHistoryMax("maxVoltage", tableRow.index)
				readonly property real maxPower: root._trackerHistoryMax("maxPower", tableRow.index)

				QuantityObject { object: rowModel; key: "totalYield"; unit: VenusOS.Units_Energy_KiloWattHour }
				QuantityObject { object: rowModel; key: "maxVoltage"; unit: VenusOS.Units_Volt_DC }
				QuantityObject { object: rowModel; key: "maxPower"; unit: VenusOS.Units_Watt }
			}

			SolarTracker {
				id: solarTracker
				serviceUid: root.solarHistory.serviceUid
				trackerIndex: tableRow.index
				trackerCount: root.solarHistory.trackerCount
			}
		}
	}

	Item {
		width: 1
		height: isNaN(root.minimumHeight) ? 0
			: root.minimumHeight - tableSummary.height - trackerTable.height - solarDetailBox.height
	}

	SolarDetailBox {
		id: solarDetailBox

		x: Theme.geometry_solarDetailBox_horizontalMargin
		width: parent.width - (2 * x)
		visible: !root.summaryOnly
		minBatteryVoltage: root._trackerHistoryMin("minBatteryVoltage")
		maxBatteryVoltage: root._trackerHistoryMax("maxBatteryVoltage")
		maxBatteryCurrent: root._trackerHistoryMax("maxBatteryCurrent")
		timeInBulk: root._trackerHistoryTotal("timeInBulk")
		timeInAbsorption: root._trackerHistoryTotal("timeInAbsorption")
		timeInFloat: root._trackerHistoryTotal("timeInFloat")
		smallTextMode: root.smallTextMode
	}
}
