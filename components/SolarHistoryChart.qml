/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property alias solarCharger: yieldModel.targetSolarCharger
	property alias dayRange: yieldModel.dayRange

	property var _dailyHistoryDialog
	property real _maxTickValue: 1
	property int _tickCount: 5

	function _numberOfDigits(n) {
		if (n < 1) {
			return 0
		}
		let count = 0
		while (n !== 0) {
			n = Math.floor(n / 10)
			count += 1
		}
		return count
	}

	function _fitChartToMaxYield() {
		// maxForDigit is the yield rounded up to the digit for the nearest place value.
		// E.g. maximumYield=0.7 -> maxForDigit=1, 8.5 -> 10, 23.8 -> 100, 175.5 -> 1000
		let maxForDigit = Math.pow(10, _numberOfDigits(yieldModel.maximumYield))

		if (yieldModel.maximumYield > 1) {
			if (yieldModel.maximumYield < maxForDigit * 0.15) {
				// ticks = [1.5, 1, 0.5, 0] or equivalent.
				_maxTickValue = maxForDigit * 0.15
				_tickCount = 4
				return
			} else if (yieldModel.maximumYield < maxForDigit * 0.25) {
				// ticks = [2.5, 2, 1.5, 1, 0.5, 0] or equivalent.
				_maxTickValue = maxForDigit * 0.25
				_tickCount = 6
				return
			} else if (yieldModel.maximumYield < maxForDigit * 0.5) {
				// ticks = [5, 4, 3, 2, 1, 0] or equivalent.
				_maxTickValue = maxForDigit * 0.5
				_tickCount = 6
				return
			} else if (yieldModel.maximumYield < maxForDigit * 0.75) {
				// ticks = [7.5, 5, 2.5, 0] or equivalent.
				_maxTickValue = maxForDigit * 0.75
				_tickCount = 4
				return
			}
		}
		// ticks = [10, 7.5, 5, 2.5, 0] or equivalent.
		_maxTickValue = maxForDigit
		_tickCount = 5
	}

	width: parent.width
	height: parent.height

	Label {
		id: kwhLabel

		anchors {
			top: parent.top
			right: parent.right
			rightMargin: Theme.geometry.solarChart.horizontalMargin
		}
		text: "kWh" // TODO use UnitConversion unitToString() when unit conversion is updated
		color: Theme.color.font.secondary
		font.pixelSize: Theme.font.size.caption
	}

	Column {
		id: gridLinesColumn

		anchors {
			top: kwhLabel.bottom
			topMargin: Theme.geometry.solarChart.horizontalMargin
			left: parent.left
			leftMargin: Theme.geometry.solarChart.horizontalMargin
			right: parent.right
			bottom: parent.bottom
			bottomMargin: Theme.geometry.solarChart.bottomMargin
		}
		spacing: (height - (root._tickCount * Theme.geometry.solarChart.tickLine.height)) / (root._tickCount - 1)

		Repeater {
			id: gridLinesRepeater

			model: root._tickCount

			delegate: Item {
				width: parent.width
				height: Theme.geometry.solarChart.tickLine.height

				Rectangle {
					id: markerLine

					anchors {
						left: parent.left
						rightMargin: Theme.geometry.solarChart.horizontalMargin
						right: markerLabel.left
					}
					height: Theme.geometry.solarChart.tickLine.height
					color: Theme.color.listItem.separator
				}

				Label {
					id: markerLabel

					anchors {
						verticalCenter: markerLine.verticalCenter
						right: parent.right
						rightMargin: Theme.geometry.solarChart.horizontalMargin
					}
					width: Theme.geometry.solarChart.tickLabel.width
					horizontalAlignment: Text.AlignRight
					text: root._maxTickValue === 0
						  ? (model.index === gridLinesRepeater.count - 1 ? "0" : "")
						  : root._maxTickValue - (modelData * (root._maxTickValue / (root._tickCount - 1)))
					color: Theme.color.font.secondary
				}
			}
		}
	}

	Row {
		id: barRow

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.solarChart.horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry.solarChart.tickLabel.width + (2 * Theme.geometry.solarChart.horizontalMargin)
			top: kwhLabel.bottom
			bottom: parent.bottom
			bottomMargin: Theme.geometry.solarChart.bottomMargin
		}
		spacing: barRepeater.count >= 30 ? Theme.geometry.solarChart.bar.spacing.thirtyDays
			   : barRepeater.count >= 14 ? Theme.geometry.solarChart.bar.spacing.fourteenDays
			   : Theme.geometry.solarChart.bar.spacing.sevenDays

		Repeater {
			id: barRepeater

			model: SolarYieldModel {
				id: yieldModel

				onMaximumYieldChanged: Qt.callLater(root._fitChartToMaxYield)
			}

			delegate: MouseArea {
				id: barMouseArea

				property alias coloredBar: coloredBar

				width: (barRow.width - (barRow.spacing * (barRepeater.count - 1))) / barRepeater.count
				height: parent.height

				onClicked: {
					if (!root._dailyHistoryDialog) {
						root._dailyHistoryDialog = dailyHistoryDialogComponent.createObject(Global.dialogLayer)
					}
					root._dailyHistoryDialog.day = yieldModel.dayRange[0] + model.index
					root._dailyHistoryDialog.open()
				}

				Rectangle {
					id: coloredBar

					anchors {
						bottom: parent.bottom
						bottomMargin: Theme.geometry.solarChart.tickLine.height
					}
					width: parent.width
					height: (model.yieldKwh || 0) * (gridLinesColumn.height / root._maxTickValue)
					radius: Theme.geometry.solarChart.bar.radius

					// This base rectangle ensures the bar is not transparent when pressed
					color: barMouseArea.containsPress ? Theme.color.background.primary : "transparent"

					Rectangle {
						anchors.fill: parent
						radius: Theme.geometry.solarChart.bar.radius
						color: barMouseArea.containsPress ? Theme.color.dimBlue : Theme.color.ok
					}
				}
			}
		}
	}

	Component {
		id: dailyHistoryDialogComponent

		SolarDailyHistoryDialog {
			solarCharger: root.solarCharger
			minimumDay: yieldModel.dayRange[0]
			maximumDay: yieldModel.dayRange[1] - 1
			highlightBarForDay: function(day) {
				const container = barRepeater.itemAt(day - yieldModel.dayRange[0])
				if (!container) {
					console.warn("highlightBarSource() failed, no repeater item at day:", day, "dayRange:", root.dayRange)
					return null
				}
				return container.coloredBar
			}
		}
	}
}
