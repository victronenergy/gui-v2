/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Item {
	id: root

	property string activeGranularity: "week"
	property var granularityAndSelectedPeriod: ({
		"hour": 0,
		"day": 0,
		"week": 0,
		"month": 0,
	})

	property date startDate: _calculateDate(activeGranularity, granularityAndSelectedPeriod[activeGranularity], true)
	property date endDate: _calculateDate(activeGranularity, granularityAndSelectedPeriod[activeGranularity], false)
	property bool mondayAsWeekStart: true

	// TODO: localisation, depends on activeGranularity, etc.
	property var graphXTicks: ["M", "T", "W", "T", "F", "S", "S"]
	property var graphXTickAmounts: {
		var temp = []
		for (let i = 0; i < graphAmounts.length; ++i) {
			var subAmounts = graphAmounts[i]
			var subAmount = 0
			for (let j = 0; j < subAmounts.length; ++j) {
				subAmount += subAmounts[j]
			}
			temp[i] = subAmount
		}
		return temp
	}
	property var graphAmounts: [
		[1900, 1500, 501],
		[1800, 1400, 401],
		[500, 350, 51],
		[1920, 1300, 701],
		[3000, 1800, 802],
		[1800, 1500, 461],
		[2300, 2000, 622]
	]
	property var graphLegend: [
		{ "device": "Device A", "color": "#224B78" },
		{ "device": "Device B", "color": "#387DC5" },
		{ "device": "Device C", "color": "#5EC2F7" },
	]

	Item {
		id: selectorBar
		height: Math.max(dateSelector.height, kwhLabel.height, tabButtonRow.height)
		width: parent.width

		Row {
			id: dateSelector

			anchors {
				left: parent.left
				leftMargin: Theme.horizontalPageMargin
				verticalCenter: parent.verticalCenter
			}

			height: Math.max(prevDateButton.height, dateSpanLabel.height)

			Button {
				id: prevDateButton
				width: 30
				text: "<"
				onClicked: {
					var currPeriodIncrement = root.granularityAndSelectedPeriod[root.activeGranularity]
					currPeriodIncrement--
					root.granularityAndSelectedPeriod[root.activeGranularity] = currPeriodIncrement
					root.activeGranularityChanged() // force re-evaluation
				}
			}
			Label {
				id: dateSpanLabel
				width: 260
				anchors.verticalCenter: parent.verticalCenter
				horizontalAlignment: Text.AlignHCenter
				text: {
					// TODO: localisation etc.
					switch (root.activeGranularity) {
						case "hour": return _yyyymmdd(root.startDate) + " "
									+ _hhMM(root.startDate) + " -> "
									+ _hhMM(root.endDate)
						case "day": return _yyyymmdd(root.startDate)
						case "week": return _yyyymmdd(root.startDate) + " -> " + _yyyymmdd(root.endDate)
						case "month": return _yyyymmdd(root.startDate) + " -> " + _yyyymmdd(root.endDate)
						default: return "???"
					}
				}
			}
			 Button {
				id: nextDateButton
				width: 30
				text: ">"
				onClicked: {
					var currPeriodIncrement = root.granularityAndSelectedPeriod[root.activeGranularity]
					currPeriodIncrement++
					root.granularityAndSelectedPeriod[root.activeGranularity] = currPeriodIncrement
					root.activeGranularityChanged() // force re-evaluation
				}
			}
		}

		Label {
			id: kwhLabel
			anchors.centerIn: parent
			text: "12345 kWh"
		}

		Row {
			id: tabButtonRow

			anchors {
				right: parent.right
				rightMargin: Theme.horizontalPageMargin
				verticalCenter: parent.verticalCenter
			}

			height: Math.max(hourButton.height, dayButton.height, weekButton.height, monthButton.height)

			TabButton {
				id: hourButton
				//% "Hour"
				//: Button allows the user to see solar yield history for last hour
				text: qsTrId("solar_yield_history_button_hour")
				onClicked: root.activeGranularity = "hour"
			}
			TabButton {
				id: dayButton
				//% "Day"
				//: Button allows the user to see solar yield history for last day
				text: qsTrId("solar_yield_history_button_day")
				onClicked: root.activeGranularity = "day"
			}
			TabButton {
				id: weekButton
				//% "Week"
				//: Button allows the user to see solar yield history for last week
				text: qsTrId("solar_yield_history_button_week")
				onClicked: root.activeGranularity = "week"
			}
			TabButton {
				id: monthButton
				//% "Month"
				//: Button allows the user to see solar yield history for last month
				text: qsTrId("solar_yield_history_button_month")
				onClicked: root.activeGranularity = "month"
			}
		}
	}

	Item {
		id: graph

		anchors {
			top: selectorBar.bottom
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		
		height: barsRow.height + amountsRow.height + ticksRow.height + legendBar.height
		property int hspacePerBar: width/graphXTicks.length
		property color midColor: "#2B5A8C"

		Rectangle {
			id: bgRect
			anchors {
				top: parent.top
				bottom: amountsRow.bottom
				left: parent.left
				right: parent.right
			}
			color: Theme.okSecondaryColor
		}
		Rectangle {
			id: topLine
			anchors.top: parent.top
			height: 1
			width: parent.width
			color: graph.midColor
		}
		Shape {
			id: midLine
			y: bottomLine.y / 2
			width: parent.width
			height: 1
			ShapePath {
				strokeColor: graph.midColor
				strokeWidth: 1
				strokeStyle: ShapePath.DashLine
				dashPattern: [8,8]
				startX: 0
				startY: 0
				PathLine { x: parent.width; y: 0 }
			}
		}
		Rectangle {
			id: bottomLine
			anchors.bottom: amountsRow.top
			height: 1
			width: parent.width
			color: graph.midColor
		}
		Row {
			id: barsRow
			anchors.bottom: amountsRow.top
			height: 200
			width: parent.width

			property int barYPadding: 20
			property real maxBarAmount: Math.max(...root.graphXTickAmounts)
			property real fractionalHeight: (height - barYPadding) / maxBarAmount

			Repeater {
				model: root.graphAmounts
				height: parent.height
				Column {
					id: barColumn
					anchors.bottom: parent.bottom
					width: graph.hspacePerBar
					property var currBarAmounts: {
						var arr = modelData
						arr.reverse()
						return arr
					}
					property var currBarColors: {
						var arr = []
						for (let i = 0; i < root.graphLegend.length; ++i) {
							arr[i] = root.graphLegend[i].color
						}
						arr.reverse()
						return arr
					}
					Repeater {
						width: parent.width
						model: parent.currBarAmounts
						Rectangle {
							anchors.horizontalCenter: parent.horizontalCenter
							width: 24 // TODO - handle 7" size if it is different
							height: barsRow.fractionalHeight * modelData
							color: barColumn.currBarColors[index]
						}
					}
				}
			}
		}
		Row {
			id: amountsRow
			height: 32
			anchors.bottom: ticksRow.top
			Repeater {
				model: root.graphXTickAmounts
				height: parent.height
				Label {
					width: graph.hspacePerBar
					height: parent.height
					text: modelData
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}
		}
		Row {
			id: ticksRow
			height: 25
			anchors.bottom: legendBar.top
			Repeater {
				model: root.graphXTicks
				height: parent.height
				Label {
					width: graph.hspacePerBar
					height: parent.height
					text: modelData
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}
		}
		Row {
			id: legendBar
			height: 50
			anchors {
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			}
			Repeater {
				model: root.graphLegend
				height: parent.height/2
				Item {
					property var legendData: modelData
					height: parent.height
					width: root.width/root.graphLegend.length
					Item {
						height: parent.height
						width: legendSwatch.width + Theme.marginSmall + legendLabel.width
						anchors.centerIn: parent
						Rectangle {
							id: legendSwatch
							anchors.verticalCenter: parent.verticalCenter
							anchors.left: parent.left
							color: legendData.color
							width: 16
							height: width
							radius: 2
						}
						Label {
							id: legendLabel
							anchors.verticalCenter: parent.verticalCenter
							anchors.right: parent.right
							text: legendData.device
						}
					}
				}
			}
		}
	}

	function _calculateDate(granularity, periodIncrement, getStartDate) {
		var currDate = new Date()
		var adjustedDate
		switch (granularity) {
			case "hour":
				adjustedDate = _hourDate(currDate, getStartDate, periodIncrement)
				break
			case "day":
				adjustedDate = _dayDate(currDate, getStartDate, periodIncrement)
				break
			case "week":
				adjustedDate = _dayOfWeek(currDate, getStartDate, root.mondayAsWeekStart, periodIncrement)
				break
			case "month":
				adjustedDate = _dayOfMonth(currDate, getStartDate, periodIncrement)
				break
		}
		return adjustedDate
	}

	function _hourDate(currDate, getStartDate, periodIncrement) {
		var date = new Date(currDate)
		date.setHours(currDate.getHours() + periodIncrement)
		date.setMinutes(getStartDate ? 0 : 59)
		date.setSeconds(getStartDate ? 0 : 50)
		date.setMilliseconds(getStartDate ? 0 : 999)
		return date
	}

	function _dayDate(currDate, getStartDate, periodIncrement) {
		var date = new Date(currDate)
		date.setDate(currDate.getDate() + periodIncrement)
		date.setHours(getStartDate ? 0 : 23)
		date.setMinutes(getStartDate ? 0 : 59)
		date.setSeconds(getStartDate ? 0 : 50)
		date.setMilliseconds(getStartDate ? 0 : 999)
		return date
	}

	// get the first (or last) day of the week (which contains currDate incremented by n weeks)
	function _dayOfWeek(currDate, getFirstDay, useMondayAsFirstDay, periodIncrement) {
		var date = new Date(currDate)
		date.setDate(date.getDate() + 7*periodIncrement)
		date.setDate(date.getDate()
			- date.getDay()
			+ (getFirstDay
				? (useMondayAsFirstDay ? 0 : (date.getDay() === 0 ? -6 : 1))
				: (useMondayAsFirstDay ? 7 : 6)))
		date.setHours(getFirstDay ? 0 : 23)
		date.setMinutes(getFirstDay ? 0 : 59)
		date.setSeconds(getFirstDay ? 0 : 50)
		date.setMilliseconds(getFirstDay ? 0 : 999)

		return date
	}

	// get the first (or last) day of the month (which contains currDate incremented by n months)
	function _dayOfMonth(currDate, getFirstDay, periodIncrement) {
		var date = new Date(currDate)

		var i = 0
		if (periodIncrement > 0) {
			while (i < periodIncrement) {
				date.setMonth(date.getMonth() + 1)
				i++
			}
		} else if (periodIncrement < 0) {
			while (i > periodIncrement) {
				date.setMonth(date.getMonth() - 1)
				i--
			}
		}

		var daysInMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate()
		date.setDate(getFirstDay ? 1 : daysInMonth)
		date.setHours(getFirstDay ? 0 : 23)
		date.setMinutes(getFirstDay ? 0 : 59)
		date.setSeconds(getFirstDay ? 0 : 50)
		date.setMilliseconds(getFirstDay ? 0 : 999)

		return date
	}

	function _yyyymmdd(date) {
		var yyyymmdd = String((10000 * date.getFullYear()) + (100 * (date.getMonth() + 1)) + date.getDate())
		var withSeps = yyyymmdd.slice(0,4) + "/" + yyyymmdd.slice(4,6) + "/" + yyyymmdd.slice(6)
		return withSeps
	}

	function _hhMM(date) {
		var hhMM = String((10000 * 1) + (100 * date.getHours()) + date.getMinutes())
		var withSeps = hhMM.slice(1,3) + ":" + hhMM.slice(3)
		return withSeps
	}
}
