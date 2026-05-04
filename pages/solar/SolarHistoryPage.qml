/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string serviceUid
	readonly property alias solarHistory: solarHistory

	title: CommonWords.history

	SolarHistory {
		id: solarHistory
		serviceUid: root.serviceUid
	}

	TabBar {
		id: tabBar

		anchors.horizontalCenter: parent.horizontalCenter
		width: Theme.screenSize === Theme.Portrait
			   ? parent.width - (2 * Theme.geometry_page_content_horizontalMargin)
			   : Theme.geometry_solarHistoryPage_tabBar_width
		model: [
			//% "Table view"
			{ value: qsTrId("charger_history_table_view") },
			//% "Chart"
			{ value: qsTrId("charger_history_chart"), enabled: currentIndex === 1 || daysComboBox.currentIndex >= 2 },
		]

		// Update combo box imperatively to avoid messing up its currentIndex when changing models.
		onCurrentIndexChanged: {
			const prevComboIndex = daysComboBox.currentIndex
			if (currentIndex === 0) {
				daysComboBox.model = daysComboBox.tableModeOptions
				daysComboBox.currentIndex = prevComboIndex + 2
			} else {
				daysComboBox.model = daysComboBox.chartModeOptions
				daysComboBox.currentIndex = prevComboIndex - 2
			}
		}

		focus: true
		KeyNavigation.right: Theme.screenSize === Theme.Portrait ? null : daysComboBox
		KeyNavigation.down: Theme.screenSize === Theme.Portrait ? daysComboBox : chart
	}

	ComboBox {
		id: daysComboBox

		readonly property var tableModeOptions: [
			{ text: CommonWords.today, dayRange: [0, 1] },
			{ text: CommonWords.yesterday, dayRange: [1, 2] }
		].concat(chartModeOptions)

		readonly property var chartModeOptions: {
			let options = []
			if (solarHistory.daysAvailable <= 2) {
				// MPPT chargers connected via VE.CAN only have 2 days of history (i.e. today and
				// yesterday), so charts are not available for these devices.
				return options
			}
			const dayRanges = [7, 14, 31]
			for (let i = 0; i < dayRanges.length; ++i) {
				const numberOfDays = Math.min(solarHistory.daysAvailable, dayRanges[i])
				//: %1 = number of days of solar history that will be shown
				//% "Last %1 days"
				const optionText = qsTrId("charger_history_last_x_days")
				options.push({ text: optionText.arg(numberOfDays), dayRange: [0, numberOfDays] })
				if (numberOfDays >= solarHistory.daysAvailable) {
					break
				}
			}
			return options
		}

		anchors {
			right: parent.right
			rightMargin: Theme.geometry_page_content_horizontalMargin
			top: Theme.screenSize === Theme.Portrait ? tabBar.bottom : tabBar.top
			topMargin: Theme.screenSize === Theme.Portrait ? Theme.geometry_listItem_content_verticalMargin : 0
		}
		width: Theme.screenSize === Theme.Portrait
			   ? parent.width - (2 * Theme.geometry_page_content_horizontalMargin)
			   : implicitWidth
		model: tableModeOptions
		displayText: model[currentIndex].text
		keyNavigationDirection: Theme.screenSize === Theme.Portrait ? Qt.Horizontal : Qt.Vertical

		// Set the priority to allow the ComboBox key shortcuts to override the key navigation.
		KeyNavigation.priority: popup.opened ? KeyNavigation.AfterItem : KeyNavigation.BeforeItem
		KeyNavigation.down: Theme.screenSize === Theme.Portrait ? chart : null
		KeyNavigation.up: Theme.screenSize === Theme.Portrait ? tabBar : null
		KeyNavigation.left: Theme.screenSize === Theme.Portrait ? null : tabBar
	}

	ListItemBackground {
		anchors {
			top: tableView.top
			bottom: chart.visible ? chart.bottom : tableView.bottom
			left: tableView.left
			right: tableView.right
		}
	}

	SolarHistoryTableView {
		id: tableView

		// Use x/y positioning, as vertical anchor changes do not take effect as expected when
		// stretchTableVertically changes value (when switching tabs).
		x: Theme.geometry_page_content_horizontalMargin
		width: parent.width - (2 * Theme.geometry_page_content_horizontalMargin)
		y: daysComboBox.y + daysComboBox.height + Theme.geometry_listItem_content_verticalMargin
		height: stretchTableVertically ? parent.height - y - Theme.geometry_listItem_content_verticalMargin : implicitHeight

		solarHistory: root.solarHistory
		dayRange: daysComboBox.model[daysComboBox.currentIndex].dayRange
		stretchTableVertically: tabBar.currentIndex === 0

		// Since the table view contains the "totals" summary, it is always shown even when "Charts"
		// view is selected, but the tracker table and history box will be hidden in that case.
		summaryOnly: tabBar.currentIndex === 1
	}

	SolarHistoryChart {
		id: chart

		anchors {
			top: tableView.bottom
			left: parent.left
			leftMargin: Theme.geometry_page_content_horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry_page_content_horizontalMargin
			bottom: parent.bottom
			bottomMargin: Theme.geometry_page_content_verticalMargin
		}
		enabled: tabBar.currentIndex === 1
		visible: enabled
		solarHistory: root.solarHistory
		dayRange: daysComboBox.model[daysComboBox.currentIndex].dayRange
	}
}
