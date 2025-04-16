/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FocusScope {
	id: root

	property SolarHistory solarHistory
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
		if (gridLinesColumn.height <= 0) {
			return;
		}

		// maxForDigit is the yield rounded up to the digit for the nearest place value.
		// E.g. maximumYield=0.7 -> maxForDigit=1, 8.5 -> 10, 23.8 -> 100, 175.5 -> 1000
		let maxForDigit = Math.pow(10, _numberOfDigits(yieldModel.maximumYield))
		let tickCount = 0
		let maxTickValue = 0

		if (yieldModel.maximumYield > 1) {
			if (yieldModel.maximumYield < maxForDigit * 0.15) {
				// ticks = [1.5, 1, 0.5, 0] or equivalent.
				maxTickValue = maxForDigit * 0.15
				tickCount = 4
			} else if (yieldModel.maximumYield < maxForDigit * 0.25) {
				// ticks = [2.5, 2, 1.5, 1, 0.5, 0] or equivalent.
				maxTickValue = maxForDigit * 0.25
				tickCount = 6
			} else if (yieldModel.maximumYield < maxForDigit * 0.5) {
				// ticks = [5, 4, 3, 2, 1, 0] or equivalent.
				maxTickValue = maxForDigit * 0.5
				tickCount = 6
			} else if (yieldModel.maximumYield < maxForDigit * 0.75) {
				// ticks = [7.5, 5, 2.5, 0] or equivalent.
				maxTickValue = maxForDigit * 0.75
				tickCount = 4
			}
		}
		if (tickCount === 0) {
			// ticks = [10, 7.5, 5, 2.5, 0] or equivalent.
			maxTickValue = maxForDigit
			tickCount = 5
		}

		_maxTickValue = maxTickValue
		_tickCount = tickCount

		// Now update the bar heights. Do this imperatively instead of via a height binding in the
		// bar, so that the bar height is only changed after all relevant values are updated, else
		// the bar may jump in height multiple times before settling in place.
		for (let i = 0; i < barRepeater.count; ++i) {
			const bar = barRepeater.itemAt(i)
			if (bar) {
				bar.updateHeight()
			}
		}
	}

	width: parent.width
	height: parent.height

	Label {
		id: kwhLabel

		anchors {
			top: parent.top
			right: parent.right
			rightMargin: Theme.geometry_solarChart_horizontalMargin
		}
		text: Units.defaultUnitString(VenusOS.Units_Energy_KiloWattHour)
		color: Theme.color_font_secondary
		font.pixelSize: Theme.font_size_caption
	}

	Column {
		id: gridLinesColumn

		anchors {
			top: kwhLabel.bottom
			topMargin: Theme.geometry_solarChart_horizontalMargin
			left: parent.left
			leftMargin: Theme.geometry_solarChart_horizontalMargin
			right: parent.right
			bottom: parent.bottom
			bottomMargin: Theme.geometry_solarChart_bottomMargin
		}
		spacing: (height - (root._tickCount * Theme.geometry_solarChart_tickLine_height)) / (root._tickCount - 1)

		onHeightChanged: Qt.callLater(root._fitChartToMaxYield)

		Repeater {
			id: gridLinesRepeater

			model: root._tickCount

			delegate: Item {
				width: parent.width
				height: Theme.geometry_solarChart_tickLine_height

				Rectangle {
					id: markerLine

					anchors {
						left: parent.left
						rightMargin: Theme.geometry_solarChart_horizontalMargin
						right: markerLabel.left
					}
					height: Theme.geometry_solarChart_tickLine_height
					color: Theme.color_listItem_separator
				}

				Label {
					id: markerLabel

					anchors {
						verticalCenter: markerLine.verticalCenter
						right: parent.right
						rightMargin: Theme.geometry_solarChart_horizontalMargin
					}
					width: Theme.geometry_solarChart_tickLabel_width
					horizontalAlignment: Text.AlignRight
					text: root._maxTickValue === 0
						  ? (model.index === gridLinesRepeater.count - 1 ? "0" : "")
						  : root._maxTickValue - (modelData * (root._maxTickValue / (root._tickCount - 1)))
					color: Theme.color_font_secondary
				}
			}
		}
	}

	Row {
		id: barRow

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_solarChart_horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry_solarChart_tickLabel_width + (2 * Theme.geometry_solarChart_horizontalMargin)
			top: kwhLabel.bottom
			bottom: parent.bottom
			bottomMargin: Theme.geometry_solarChart_bottomMargin
		}
		spacing: barRepeater.count >= 30 ? Theme.geometry_solarChart_bar_spacing_thirtyDays
			   : barRepeater.count >= 14 ? Theme.geometry_solarChart_bar_spacing_fourteenDays
			   : Theme.geometry_solarChart_bar_spacing_sevenDays

		Repeater {
			id: barRepeater

			property int currentIndex: 0

			model: SolarYieldModel {
				id: yieldModel

				targetHistory: root.solarHistory

				onMaximumYieldChanged: Qt.callLater(root._fitChartToMaxYield)
			}

			delegate: MouseArea {
				id: barMouseArea

				property alias coloredBar: coloredBar

				function updateHeight() {
					coloredBar.height = (model.yieldKwh || 0) * (gridLinesColumn.height / root._maxTickValue)
				}

				function openHistoryDialog() {
					Global.dialogLayer.open(dailyHistoryDialogComponent, {day: yieldModel.dayRange[0] + model.index})
				}

				width: (barRow.width - (barRow.spacing * (barRepeater.count - 1))) / barRepeater.count
				height: parent.height
				focus: model.index === barRepeater.currentIndex

				onClicked: openHistoryDialog()
				Keys.onSpacePressed: openHistoryDialog()
				Keys.enabled: Global.keyNavigationEnabled
				KeyNavigation.right: barRepeater.itemAt((model.index + 1) % barRepeater.count)

				Rectangle {
					id: coloredBar

					anchors {
						bottom: parent.bottom
						bottomMargin: Theme.geometry_solarChart_tickLine_height
					}
					width: parent.width
					radius: Theme.geometry_solarChart_bar_radius

					// This base rectangle ensures the bar is not transparent when pressed
					color: barMouseArea.containsPress ? Theme.color_background_primary : "transparent"

					Rectangle {
						anchors.fill: parent
						radius: Theme.geometry_solarChart_bar_radius
						color: barMouseArea.containsPress ? Theme.color_lightBlue : Theme.color_ok
					}
				}

				KeyNavigationHighlight {
					anchors.fill: parent
					active: parent.activeFocus
				}
			}
		}
	}

	Component {
		id: dailyHistoryDialogComponent

		SolarDailyHistoryDialog {
			solarHistory: root.solarHistory
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
			onDayChanged: {
				barRepeater.currentIndex = day - yieldModel.dayRange[0]
			}
		}
	}
}
