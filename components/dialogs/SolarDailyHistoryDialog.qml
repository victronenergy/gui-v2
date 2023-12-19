/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

// This doesn't extend ModalDialog, due to the custom background layering required to show the
// selected bar from the bar chart with full opacity (undimmed) behind the dialog.
T.Dialog {
	id: root

	property alias solarCharger: tableView.solarCharger
	property int day
	property int minimumDay
	property int maximumDay
	property var highlightBarForDay

	function _refresh() {
		const now = ClockTime.currentDateTime
		now.setDate(now.getDate() - day)
		dateLabel.text = Qt.formatDate(now, "ddd d MMM")
		tableView.dayRange = [day, day + 1]

		const sourceBar = highlightBarForDay(day)
		if (!sourceBar) {
			console.warn("No highlight bar found for day", day)
			return
		}

		// forceLayout() to ensure geometry is correct before calling mapFromItem().
		tableView.forceLayout()
		const pos = background.mapFromItem(sourceBar.parent, sourceBar.x, sourceBar.y)
		highlightBar.x = pos.x
		highlightBar.y = pos.y
		highlightBar.width = sourceBar.width
		highlightBar.height = sourceBar.height
	}

	anchors.centerIn: parent
	implicitWidth: background.implicitWidth
	implicitHeight: Theme.geometry.solarDailyHistoryDialog.header.height
					+ tableView.height
					+ (errorView.visible ? errorView.collapsedHeight + Theme.geometry.solarDetailBox.verticalMargin : 0)
	verticalPadding: 0
	horizontalPadding: 0
	modal: true

	enter: Transition {
		SequentialAnimation {
			ScriptAction {
				script: {
					// Refresh the UI here, instead of in onAboutToShow, to ensure geometry is ready
					// so that the highlight bar is correctly positioned.
					root.opacity = 0
					root._refresh()
				}
			}
			NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Theme.animation.page.fade.duration }
		}
	}
	exit: Transition {
		NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: Theme.animation.page.fade.duration }
	}

	background: Rectangle {
		implicitWidth: Theme.geometry.modalDialog.width
		implicitHeight: Theme.geometry.solarDailyHistoryDialog.header.height
					+ tableView.height
					+ (errorView.visible ? errorView.collapsedHeight + Theme.geometry.solarDetailBox.verticalMargin : 0)
		radius: Theme.geometry.modalDialog.radius
		color: Theme.color.background.secondary

		DialogShadow {
			backgroundRect: parent
			dialog: root
		}

		Rectangle {
			id: highlightBar

			color: Theme.color.ok
			radius: Theme.geometry.solarChart.bar.radius
		}

		IconButton {
			anchors {
				right: parent.left
				rightMargin: Theme.geometry.solarDailyHistoryDialog.arrow.horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			icon.sourceSize.height: Theme.geometry.solarDailyHistoryDialog.arrow.icon.size
			iconColor: containsPress ? Theme.color.gray4 : Theme.color.gray5
			icon.source: "qrc:/images/icon_back_32.svg"
			visible: root.day > root.minimumDay

			onClicked: {
				root.day--
				root._refresh()
			}
		}

		IconButton {
			anchors {
				left: parent.right
				leftMargin: Theme.geometry.solarDailyHistoryDialog.arrow.horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			icon.sourceSize.height: Theme.geometry.solarDailyHistoryDialog.arrow.icon.size
			iconColor: containsPress ? Theme.color.gray4 : Theme.color.gray5
			icon.source: "qrc:/images/icon_back_32.svg"
			visible: root.day < root.maximumDay
			rotation: 180

			onClicked: {
				root.day++
				root._refresh()
			}
		}
	}

	// This must be a Rectangle to ensure highlightBar does not appear through the content.
	contentItem: Rectangle {
		radius: Theme.geometry.modalDialog.radius
		color: Theme.color.background.secondary

		Label {
			id: dateLabel

			width: parent.width
			height: Theme.geometry.solarDailyHistoryDialog.header.height
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: Theme.font.size.body1
		}

		IconButton {
			anchors {
				right: parent.right
				top: parent.top
			}
			width: Theme.geometry.solarDailyHistoryDialog.closeButton.icon.size + (2 * Theme.geometry.solarDailyHistoryDialog.closeButton.icon.margins)
			height: Theme.geometry.solarDailyHistoryDialog.closeButton.icon.size + (2 * Theme.geometry.solarDailyHistoryDialog.closeButton.icon.margins)
			icon.sourceSize.height: Theme.geometry.solarDailyHistoryDialog.closeButton.icon.size
			iconColor: Theme.color.ok
			icon.source: "qrc:/images/toast_icon_close.svg"

			onClicked: root.close()
		}

		SolarHistoryTableView {
			id: tableView

			anchors {
				top: dateLabel.bottom
				left: parent.left
				right: parent.right
			}
			smallTextMode: true
			minimumHeight: root.solarCharger.trackers.count > 1 ? NaN
				: Theme.geometry.solarDailyHistoryDialog.minimumHeight - Theme.geometry.solarDailyHistoryDialog.header.height
		}

		MouseArea {
			anchors.fill: tableView
			enabled: errorView.expanded
			onClicked: errorView.expanded = false
		}

		SolarHistoryErrorView {
			id: errorView

			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: Theme.geometry.solarDetailBox.verticalMargin
			}
			width: parent.width - (2 * Theme.geometry.solarDetailBox.verticalMargin)
			model: {
				const history = root.solarCharger.dailyHistory(root.day)
				return history ? history.errorModel : null
			}
			visible: model && model.count > 0
		}
	}
}
