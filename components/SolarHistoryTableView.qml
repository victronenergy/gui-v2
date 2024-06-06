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

		metrics.smallTextMode: root.smallTextMode
		metrics.spacing: 2*Theme.geometry_quantityTable_horizontalSpacing
		metrics.firstColumnWidth: (root.width / model.length) * 1.5  // expand tracker name column to fill 1.5 column space

		model: [
			{
				title: "",
				text: CommonWords.total,
				unit: VenusOS.Units_None,
			},
			{
				title: CommonWords.yield_kwh,
				value: root._trackerHistoryTotal("yieldKwh"),
				unit: VenusOS.Units_Energy_KiloWattHour
			},
			{
				//% "Max Voltage"
				title: qsTrId("charger_history_max_voltage"),
				value: root._trackerHistoryMax("maxPvVoltage"),
				unit: VenusOS.Units_Volt_DC
			},
			{
				//% "Max Power"
				title: qsTrId("charger_history_max_power"),
				value: root._trackerHistoryMax("maxPower"),
				unit: VenusOS.Units_Watt
			},
		]
	}

	QuantityTable {
		id: trackerTable

		bottomPadding: Theme.geometry_quantityTable_bottomMargin
		visible: !root.summaryOnly && root.solarHistory.trackerCount > 1
		headerVisible: false
		metrics.smallTextMode: root.smallTextMode
		metrics.spacing: 2*Theme.geometry_quantityTable_horizontalSpacing
		metrics.firstColumnWidth: (root.width / units.length) * 1.5  // expand tracker name column to fill 1.5 column space

		rowCount: root.solarHistory.trackerCount
		units: [
			// No 'title' property is specified, since these are same as summary headers.
			{ unit: VenusOS.Units_None },
			{ unit: VenusOS.Units_Energy_KiloWattHour },
			{ unit: VenusOS.Units_Volt_DC },
			{ unit: VenusOS.Units_Watt },
		]
		valueForModelIndex: function(trackerIndex, column) {
			if (column === 0) {
				return root.solarHistory.trackerName(trackerIndex, VenusOS.TrackerName_NoDevicePrefix)
			} else if (column === 1) {
				return root._trackerHistoryTotal("yieldKwh", trackerIndex)
			} else if (column === 2) {
				return root._trackerHistoryMax("maxVoltage", trackerIndex)
			} else if (column === 3) {
				return root._trackerHistoryMax("maxPower", trackerIndex)
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
