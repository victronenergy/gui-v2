/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls as C

Page {
	id: root

	property var solarCharger

	title: solarCharger.name

	TabBar {
		id: tabBar

		anchors.horizontalCenter: parent.horizontalCenter
		width: Theme.geometry.solarHistoryPage.tabBar.width
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
	}

	ComboBox {
		id: daysComboBox

		readonly property var tableModeOptions: [
			{ text: CommonWords.today, dayRange: [0, 1] },
			{ text: CommonWords.yesterday, dayRange: [1, 2] }
		].concat(chartModeOptions)

		readonly property var chartModeOptions: [
			//% "Last 7 days"
			{ text: qsTrId("charger_history_last_7_days"), dayRange: [0, 7] },
			//% "Last 14 days"
			{ text: qsTrId("charger_history_last_14_days"), dayRange: [0, 14] },
			//% "Last 30 days"
			{ text: qsTrId("charger_history_last_30_days"), dayRange: [0, 30] }
		]

		anchors {
			right: parent.right
			rightMargin: Theme.geometry.page.content.horizontalMargin
			verticalCenter: tabBar.verticalCenter
		}
		width: Theme.geometry.comboBox.width
		model: tableModeOptions
		displayText: model[currentIndex].text
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

		anchors {
			top: tabBar.bottom
			topMargin: Theme.geometry.listItem.content.verticalMargin
			left: parent.left
			leftMargin: Theme.geometry.page.content.horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry.page.content.horizontalMargin
		}
		minimumHeight: chart.visible ? NaN
			: root.height - tableView.y - Theme.geometry.page.content.verticalMargin - bottomPadding
		solarCharger: root.solarCharger
		dayRange: daysComboBox.model[daysComboBox.currentIndex].dayRange

		// Since the table view contains the "totals" summary, it is always shown even when "Charts"
		// view is selected, but the tracker table and history box will be hidden in that case.
		summaryOnly: tabBar.currentIndex === 1
	}

	SolarHistoryChart {
		id: chart

		anchors {
			top: tableView.bottom
			left: parent.left
			leftMargin: Theme.geometry.page.content.horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry.page.content.horizontalMargin
			bottom: parent.bottom
			bottomMargin: Theme.geometry.page.content.verticalMargin
		}
		visible: tabBar.currentIndex === 1
		solarCharger: root.solarCharger
		dayRange: daysComboBox.model[daysComboBox.currentIndex].dayRange
	}
}
